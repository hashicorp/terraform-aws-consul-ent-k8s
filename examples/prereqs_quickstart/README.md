# Example Prerequisite Configuration for Consul on EKS Module

The quickstart directory provides example code that will create one Amazon VPC
and two EKS clusters along with an AWS Secrets Manager secret to store Consul
federation data.

The Amazon VPC will have the following:
- Three public subnets
- Three NAT gateways (one in each public subnet)
- Three private subnets (the nodes from the EKS managed node group will be
  deployed here).

## How to Use This Module

- Install the [AWS CLI](https://aws.amazon.com/cli/) and ensure your AWS
  credentials are [configured
  correctly](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)

- Install [kubectl](https://kubernetes.io/docs/reference/kubectl/)

Run `terraform init` and `terraform apply` inside this directory to create the
VPC and two EKS clusters. The whole provisioning process takes approximately 20
minutes.

## Required Variables

- `eks_1_cluster_name` - The name of your first EKS cluster
- `eks_2_cluster_name` - The name of your second EKS cluster
- `resource_name_prefix` - Prefix for resource names in VPC infrastructure

Note: the default AWS region is `us-east-1`. If you change this value, please be
sure to update [availability
zones](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-availability-zones)
via the `azs` variable so they match the AWS region you have chosen.

# A note on using kubectl

If you want to run `kubectl` commands against your cluster, be sure to update
your kubeconfig as shown for each cluster:

```shell
$ aws eks update-kubeconfig --region "<your region>" --name "<name-of-cluster>"
```

If you want to switch kubectl
[context](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/#context),
be sure to run the following:

```shell
$ kubectl config use-context "<your cluster ARN>"
```

# Note:

- If you have used the main module to install the Consul helm chart, please be
  sure to run `terraform destroy` from there to uninstall the helm chart BEFORE
  destroying these prerequisite resources. Failure to uninstall Consul from the
  main module will result in a failed `terraform destroy` and lingering
  resources in your VPC.
