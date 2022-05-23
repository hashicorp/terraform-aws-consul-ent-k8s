/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

terraform {
  cloud {
    organization = "hc-tfc-dev"

    workspaces {
      tags = [
        "integrationtest",
      ]
    }
  }
}

provider "aws" {
  region = var.region
}

module "app" {
  source = "../../examples/apps"

  aws_region   = var.region
  cluster_name = var.cluster_name
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster_auth" {
  name = data.aws_eks_cluster.cluster.id
}

provider "kubernetes" {
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster_auth.token
}

# TODO: add external access to example app
# resource "kubernetes_service" "dashboard_load_balancer" {
#   metadata {
#     name      = "dashboard-load-balancer"
#     namespace = "consul"

#     labels = {
#       app = "dashboard"
#     }
#   }

#   spec {
#     type = "LoadBalancer"

#     selector = {
#       app = "dashboard"
#     }

#     port {
#       name        = "http"
#       protocol    = "TCP"
#       port        = 80
#       target_port = 9002
#     }
#   }
# }

# data "kubernetes_service" "dashboard_load_balancer" {
#   metadata {
#     name      = kubernetes_service.dashboard_load_balancer.metadata[0].name
#     namespace = kubernetes_service.dashboard_load_balancer.metadata[0].namespace
#   }
# }

# data "http" "dashboard" {
#   url = "http://${data.kubernetes_service.dashboard_load_balancer.status.0.load_balancer.0.ingress.0.hostname}"
# }
