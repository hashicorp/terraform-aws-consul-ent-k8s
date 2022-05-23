/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster_auth" {
  name = data.aws_eks_cluster.cluster.id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster_auth.token
}

resource "kubernetes_namespace" "consul" {
  metadata {
    name = var.kubernetes_namespace
  }
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster_auth.token
  }
}

provider "kubectl" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster_auth.token
  load_config_file       = false
}

module "helm_install" {
  source = "./modules/helm_install"

  aws_secrets_manager_name  = var.aws_secrets_manager_name
  chart_name                = var.chart_name
  chart_repository          = var.chart_repository
  consul_helm_chart_version = var.consul_helm_chart_version
  consul_license            = var.consul_license
  consul_namespace          = var.consul_namespace
  consul_version            = var.consul_version
  create_namespace          = var.create_namespace
  kubernetes_namespace      = kubernetes_namespace.consul.metadata[0].name
  primary_datacenter        = var.primary_datacenter
  release_name              = var.release_name
  server_replicas           = var.server_replicas
}
