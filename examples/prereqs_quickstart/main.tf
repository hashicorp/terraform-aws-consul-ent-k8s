/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./aws-vpc/"

  azs                  = var.azs
  common_tags          = var.tags
  resource_name_prefix = var.resource_name_prefix
}

module "secrets_manager" {
  source = "./secrets/"

  resource_name_prefix = var.resource_name_prefix
}

module "eks_1" {
  source = "./eks/"

  cluster_name         = var.eks_1_cluster_name
  permissions_boundary = var.permissions_boundary
  subnet_ids           = module.vpc.subnet_ids
  tags                 = var.tags
  vpc_id               = module.vpc.vpc_id

  depends_on = [
    # VPC module contains resources (e.g. NAT Gateways) that should be
    # deployed before any EKS resources are created
    module.vpc,
  ]
}

module "eks_2" {
  source = "./eks/"

  cluster_name         = var.eks_2_cluster_name
  permissions_boundary = var.permissions_boundary
  subnet_ids           = module.vpc.subnet_ids
  tags                 = var.tags
  vpc_id               = module.vpc.vpc_id

  depends_on = [
    # VPC module contains resources (e.g. NAT Gateways) that should be
    # deployed before any EKS resources are created
    module.vpc,
  ]
}
