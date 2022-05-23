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
    testingtoolsk8s = {
      source  = "app.terraform.io/hc-tfc-dev/testingtoolsk8s"
      version = "~> 0.1.0"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster_auth" {
  name = data.aws_eks_cluster.cluster.id
}

provider "testingtoolsk8s" {
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster_auth.token
}

resource "testingtoolsk8s_exec" "consul_wan_members" {
  namespace = "consul"
  pod       = "consul-server-4"

  command = [
    "consul",
    "members",
    "-wan",
  ]
}

output "consul_wan_members" {
  value = testingtoolsk8s_exec.consul_wan_members.stdout
}

data "aws_instances" "cluster" {
  instance_state_names = [
    "running",
  ]

  instance_tags = {
    "eks:cluster-name" = var.cluster_name
  }
}

data "aws_instance" "node_group_node" {
  instance_id = data.aws_instances.cluster.ids[0]
}

output "node_group_root_block_device_volume_type" {
  value = tolist(data.aws_instance.node_group_node.root_block_device)[0].volume_type
}
