# Consul Enterprise on EKS Module

This is a Terraform module for provisioning two
[federated](https://www.consul.io/docs/k8s/installation/multi-cluster) Consul
Enterprise clusters on [EKS](https://aws.amazon.com/eks/) using Consul version
1.11.15+.

## How to Use This Module

- Ensure your AWS credentials are [configured
  correctly](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
  and have permission to use the following AWS services:
    - Amazon EC2
    - Amazon EKS
    - AWS Identity & Access Management (IAM)
    - AWS Key Management System (KMS)
    - Amazon Secrets Manager
    - Amazon VPC

- Install [kubectl](https://kubernetes.io/docs/reference/kubectl/) (this will be
  used to verify Consul cluster federation status).

- This module assumes you have an existing VPC and two existing EKS clusters
  along with an AWS secrets manager that you can use for Consul federation
  secrets. If you do not, you may use the following
  [quickstart](https://github.com/hashicorp/terraform-aws-consul-ent-k8s/tree/main/examples/prereqs_quickstart)
  to deploy these resources.

- If you would like deploy this module into existing EKS clusters, please make sure they able to access each other at their [Amazon EKS cluster endpoint](https://docs.aws.amazon.com/eks/latest/userguide/cluster-endpoint.html).

- You will create two files named `main.tf` and place them each in a different
  directory.

- Your first `main.tf` should look like this (note that `primary_datacenter` is
  set to `true`). This will install your primary Consul cluster.

```hcl
provider "aws" {
  region = "<your AWS region>"
}

module "primary_consul_cluster" {
  source  = "hashicorp/consul-ent-k8s/aws"
  version = "0.1.0"

  aws_secrets_manager_name = "<name of the AWS secrets manager you will use for Consul federation secrets>"
  consul_license           = file("<path to Consul Enterprise license")
  cluster_name             = "<name of your first EKS cluster>"
  primary_datacenter       = true
}
```

- Your second `main.tf` should look like this (note that `primary_datacenter` is
  set to `false`). This will install your secondary Consul cluster.

```hcl
provider "aws" {
  region = "<your AWS region>"
}

module "secondary_consul_cluster" {
  source  = "hashicorp/consul-ent-k8s/aws"
  version = "0.1.0"

  aws_secrets_manager_name = "<name of the AWS secrets manager you will use for Consul federation secrets>"
  consul_license           = file("<path to Consul Enterprise license")
  cluster_name             = "<name of your second EKS cluster>"
  primary_datacenter       = false
}
```

- Run `terraform init` and `terraform apply` first in the directory that
  contains the `main.tf` file that will set up your primary Consul cluster. Wait
  for the apply to complete before moving on to the next step.

- Run `terraform init` and `terraform apply` in the directory containing the
  `main.tf` file that will set up your secondary Consul cluster. Once this is
  complete, you should have two federated Consul clusters. 

To verify that both datacenters are federated, run the consul members -wan
command on one of the Consul server pods (if you need help on configuring kubectl, please see the [following](https://github.com/hashicorp/terraform-aws-consul-ent-k8s/blob/main/examples/prereqs_quickstart/README.md#a-note-on-using-kubectl)):

```shell
$ kubectl exec statefulset/consul-server --namespace=consul -- consul members -wan
```

Your output should show servers from both `dc1` and `dc2` similar to what is
show below:

```shell
Node                 Address           Status  Type    Build       Protocol  DC   Partition  Segment
consul-server-0.dc1  10.0.7.15:8302    alive   server  1.11.5+ent  2         dc1  default    <all>
consul-server-0.dc2  10.0.41.80:8302   alive   server  1.11.5+ent  2         dc2  default    <all>
consul-server-1.dc1  10.0.77.40:8302   alive   server  1.11.5+ent  2         dc1  default    <all>
consul-server-1.dc2  10.0.27.88:8302   alive   server  1.11.5+ent  2         dc2  default    <all>
consul-server-2.dc1  10.0.40.168:8302  alive   server  1.11.5+ent  2         dc1  default    <all>
consul-server-2.dc2  10.0.77.252:8302  alive   server  1.11.5+ent  2         dc2  default    <all>
consul-server-3.dc1  10.0.4.180:8302   alive   server  1.11.5+ent  2         dc1  default    <all>
consul-server-3.dc2  10.0.28.185:8302  alive   server  1.11.5+ent  2         dc2  default    <all>
consul-server-4.dc1  10.0.91.5:8302    alive   server  1.11.5+ent  2         dc1  default    <all>
consul-server-4.dc2  10.0.59.144:8302  alive   server  1.11.5+ent  2         dc2  default    <all>
```

You can also use the consul catalog services command with the -datacenter flag
to ensure each datacenter can read each other's services. In this example, the
kubectl context is `dc1` and is querying for the list of services in `dc2`:

```shell
$ kubectl exec statefulset/consul-server --namespace=consul -- consul catalog services -datacenter dc2
```

Your output should show the following:

```shell
consul
mesh-gateway
```

## Deploying Example Applications

To deploy and configure some example applications, please see the
[apps](https://github.com/hashicorp/terraform-aws-consul-ent-k8s/tree/main/examples/apps)
directory.

**NOTE: when running `terraform destroy` on this module to uninstall Consul,
please run `terraform destroy` on your secondary Consul cluster and wait for it
to complete before destroying your primary consul cluster.**

## License

This code is released under the Mozilla Public License 2.0. Please see
[LICENSE](https://github.com/hashicorp/terraform-aws-consul-ent-k8s/blob/main/LICENSE)
for more details.

