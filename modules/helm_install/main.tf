/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

resource "helm_release" "consul_primary" {
  count            = var.primary_datacenter ? 1 : 0
  chart            = var.chart_name
  create_namespace = var.create_namespace
  name             = var.release_name
  namespace        = var.kubernetes_namespace
  repository       = var.chart_repository
  version          = var.consul_helm_chart_version

  values = [
    templatefile("${path.module}/templates/values-dc1.yaml", {
      consul_version  = var.consul_version
      server_replicas = var.server_replicas
      }
    )
  ]
}

resource "helm_release" "consul_secondary" {
  count            = var.primary_datacenter ? 0 : 1
  chart            = var.chart_name
  create_namespace = var.create_namespace
  name             = var.release_name
  namespace        = var.kubernetes_namespace
  repository       = var.chart_repository
  version          = var.consul_helm_chart_version

  values = [
    templatefile("${path.module}/templates/values-dc2.yaml", {
      consul_version  = var.consul_version
      server_replicas = var.server_replicas
      }
    )
  ]
  depends_on = [kubernetes_secret.federation_secret[0]]
}

data "aws_region" "current" {}

resource "aws_secretsmanager_secret_version" "federation" {
  count         = var.primary_datacenter ? 1 : 0
  secret_id     = var.aws_secrets_manager_name
  secret_string = jsonencode(data.kubernetes_secret.federation_secret[0].data)
}

resource "kubernetes_secret" "consul_license" {
  metadata {
    name      = "consul-ent-license"
    namespace = var.kubernetes_namespace
  }

  data = {
    "key" = var.consul_license
  }
}

data "kubernetes_secret" "federation_secret" {
  count = var.primary_datacenter ? 1 : 0
  metadata {
    name      = "consul-federation"
    namespace = var.kubernetes_namespace
  }

  depends_on = [helm_release.consul_primary[0]]
}

data "aws_secretsmanager_secret" "federation" {
  count = var.primary_datacenter ? 0 : 1
  name  = var.aws_secrets_manager_name
}

data "aws_secretsmanager_secret_version" "federation" {
  count     = var.primary_datacenter ? 0 : 1
  secret_id = data.aws_secretsmanager_secret.federation[0].id
}

resource "kubernetes_secret" "federation_secret" {
  count = var.primary_datacenter ? 0 : 1
  metadata {
    name      = "consul-federation"
    namespace = var.kubernetes_namespace
  }

  data = jsondecode(data.aws_secretsmanager_secret_version.federation[0].secret_string)
  depends_on = [
    data.aws_secretsmanager_secret_version.federation[0]
  ]
}

resource "kubectl_manifest" "proxy_defaults" {
  count     = var.primary_datacenter ? 1 : 0
  yaml_body = <<YAML
apiVersion: consul.hashicorp.com/v1alpha1
kind: ProxyDefaults
metadata:
  name: global
  namespace: "${var.kubernetes_namespace}"
spec:
  meshGateway:
    mode: 'local'
YAML

  depends_on = [helm_release.consul_primary[0]]
}
