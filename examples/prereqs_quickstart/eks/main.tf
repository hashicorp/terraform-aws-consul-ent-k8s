/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

resource "aws_eks_cluster" "cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster.arn
  tags     = var.tags

  # version doesn't need to be specified until it's time to upgrade
  version = var.cluster_version

  vpc_config {
    subnet_ids = var.subnet_ids

    security_group_ids = [
      aws_security_group.cluster.id,
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster-AmazonEKSClusterPolicy
  ]
}

# Create EKS cluster node group

resource "aws_eks_node_group" "node" {
  cluster_name           = aws_eks_cluster.cluster.name
  node_group_name_prefix = var.eks_managed_node_group_name_prefix
  node_role_arn          = aws_iam_role.eks_nodes.arn
  subnet_ids             = var.subnet_ids

  scaling_config {
    desired_size = 5
    max_size     = 5
    min_size     = 5
  }

  launch_template {
    id      = aws_launch_template.eks_managed_node_group.id
    version = aws_launch_template.eks_managed_node_group.latest_version
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.AmazonSSMManagedInstanceCore,
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_template" "eks_managed_node_group" {
  instance_type          = "m5.large"
  update_default_version = true

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_type           = "gp3"
      volume_size           = 100
      delete_on_termination = true
    }
  }
}

