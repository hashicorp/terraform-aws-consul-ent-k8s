/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
}

variable "cluster_name" {
  type        = string
  description = "Name of EKS cluster"
}

variable "kubernetes_namespace" {
  type        = string
  default     = "consul"
  description = "The namespace to install Consul/k8s components in"
}

