/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

output "cluster_arn" {
  value = aws_eks_cluster.cluster.arn
}

output "cluster_ca_cert" {
  value = base64decode(aws_eks_cluster.cluster.certificate_authority[0].data)
}

output "cluster_name" {
  value = aws_eks_cluster.cluster.id
}

output "kube_api_endpoint" {
  value = aws_eks_cluster.cluster.endpoint
}

