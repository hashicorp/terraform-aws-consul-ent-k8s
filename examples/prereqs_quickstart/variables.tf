/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "us-east-1"
}

variable "azs" {
  description = "availability zones to use in AWS region"
  type        = list(string)
  default = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c",
  ]
}

variable "eks_1_cluster_name" {
  description = "name of the first EKS cluster"
}

variable "eks_2_cluster_name" {
  description = "name of the second EKS cluster"
}

variable "permissions_boundary" {
  description = "IAM Managed Policy to serve as permissions boundary for created IAM Roles"
  type        = string
  default     = null
}

variable "resource_name_prefix" {
  description = "Prefix for resource names in VPC infrastructure"
}

variable "tags" {
  default = {}
  type    = map(any)
}

