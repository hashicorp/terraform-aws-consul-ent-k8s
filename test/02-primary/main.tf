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

module "consul" {
  source = "../../"

  aws_secrets_manager_name = var.secrets_manager_name
  consul_license           = var.consul_license
  cluster_name             = var.cluster_name
  primary_datacenter       = true
}
