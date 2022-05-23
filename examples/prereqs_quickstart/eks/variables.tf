/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  default = "1.22"
  type    = string
}

variable "eks_managed_node_group_name_prefix" {
  description = "Name prefix for EKS managed node group"
  type        = string
  default     = null
}

variable "permissions_boundary" {
  description = "IAM Managed Policy to serve as permissions boundary for created IAM Roles"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "Subnets to deploy EKS node into"
  type        = list(string)
}

variable "tags" {
  default = {}
  type    = map(any)
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where EKS will be deployed"
}
