/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

output "eks_1_cluster_arn" {
  value = module.eks_1.cluster_arn
}

output "eks_1_cluster_ca_cert" {
  value = module.eks_1.cluster_ca_cert
}

output "eks_1_cluster_name" {
  value = module.eks_1.cluster_name
}

output "eks_1_kube_api_endpoint" {
  value = module.eks_1.kube_api_endpoint
}

output "eks_2_cluster_arn" {
  value = module.eks_2.cluster_arn
}

output "eks_2_cluster_ca_cert" {
  value = module.eks_2.cluster_ca_cert
}

output "eks_2_cluster_name" {
  value = module.eks_2.cluster_name
}

output "eks_2_kube_api_endpoint" {
  value = module.eks_2.kube_api_endpoint
}

output "secrets_manager_name" {
  value = module.secrets_manager.secrets_manager_name
}

output "vpc_id" {
  value = module.vpc.vpc_id
}
