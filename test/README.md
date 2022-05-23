## Overview

This test directory defines basic integration tests for the module.

## Prereqs

* Terraform or tfenv in PATH
* [Terraform Cloud credentials](https://www.terraform.io/cli/commands/login)
* Consul Enterprise license in place, via either:
  * A `consul.hclic` file in this directory (it's gitignored so you can't accidentally commit it), or
  * The `TEST_CONSUL_ENT_LICENSE` environment variable

## Use

```
go test -v -timeout 120m
```

Optional environment variables:
  * `DEPLOY_ENV` - set this to change the prefix applied to resource names.
  * `AWS_DEFAULT_REGION` - set the AWS region in which resources are deployed
  * `AWS_PERMISSIONS_BOUNDARY` - this can be set when deploying with a limited-permission IAM principle (i.e. when running in CI) to create IAM Roles with the specified IAM Managed Policy ARN as their permissions boundary
  * `TEST_CONSUL_ENT_LICENSE` - See Prereqs above about options for providing the Consul Enterprise license
  * `TEST_DONT_DESTROY_UPON_SUCCESS` - set this to skip running terraform destroy upon testing success

The `go test` will populate terraform `.auto.tfvars` in each module directory and execute `terraform apply` sequentially through them. If all deploys & tests pass, each module will be destroyed in reverse order.

### Cleaning Up

If resources aren't deleted automatically (at the end of successful tests), Terraform can be manually invoked to delete them. See the `destroy.sh` script for an example of doing this.
