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

  required_providers {
    testingtoolsaws = {
      source  = "app.terraform.io/hc-tfc-dev/testingtoolsaws"
      version = "~> 0.2.0"
    }

    # https://github.com/hashicorp/terraform-provider-http/issues/49
    http = {
      source  = "terraform-aws-modules/http"
      version = "~> 2.4"
    }
  }
}

provider "aws" {
  region = var.region
}

module "quickstart" {
  source = "../../examples/prereqs_quickstart"

  azs                  = var.azs
  aws_region           = var.region
  resource_name_prefix = var.resource_name_prefix
  tags                 = var.common_tags
  eks_1_cluster_name   = "${var.resource_name_prefix}-consul-primary"
  eks_2_cluster_name   = "${var.resource_name_prefix}-consul-secondary"
  permissions_boundary = var.permissions_boundary
}
output "primary_cluster_name" {
  value = module.quickstart.eks_1_cluster_name
}
output "secondary_cluster_name" {
  value = module.quickstart.eks_2_cluster_name
}
output "secrets_manager_name" {
  value = module.quickstart.secrets_manager_name
}

# https://github.com/aws/containers-roadmap/issues/654
# or the TF EKS resources gets more advanced support
# https://github.com/hashicorp/terraform-provider-aws/pull/11426
data "http" "wait_for_primary_cluster" {
  ca_certificate = module.quickstart.eks_1_cluster_ca_cert
  url            = format("%s/healthz", module.quickstart.eks_1_kube_api_endpoint)

  # https://github.com/terraform-aws-modules/terraform-aws-eks/pull/1253#issuecomment-784968862
  timeout = 15 * 60
}
data "http" "wait_for_secondary_cluster" {
  ca_certificate = module.quickstart.eks_2_cluster_ca_cert
  url            = format("%s/healthz", module.quickstart.eks_2_kube_api_endpoint)
  timeout        = 15 * 60
}

# This resource is just a helper used during "terraform destroy" to ensure that lingering ENIs & security groups don't cause automated tests to fail
# Works around the issue described at https://github.com/hashicorp/terraform-provider-aws/issues/20925
provider "testingtoolsaws" {
  region = var.region
}
resource "testingtoolsaws_stale_eni_with_sg_cleanup" "eks" {
  security_group_description = "^EKS created security group applied to ENI that is attached to EKS Control Plane master nodes, as well as any managed workloads\\.$"
  vpc_id                     = module.quickstart.vpc_id
}
