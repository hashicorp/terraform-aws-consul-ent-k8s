# TODO: document the following:

If you want to run commands on your EKS cluster with `kubectl`, be sure to do the following:

- update your kubeconfig file:
	
```shell
$ aws eks update-kubeconfig --region "us-east-1" --name "<name of cluster>" 
```

- use the context of your EKS cluster:

```shell
$ kubectl config use-context "<your EKS ARN>"
```

- Now you can verify everything works:

```shell
$ kubectl get svc
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   172.20.0.1   <none>        443/TCP   28h
```

- If you have used the main module to install the Consul helm chart, please be sure to run `terraform destroy` from there to uninstall the helm chart BEFORE destroying this EKS cluster. Failure to uninstall Consul from the main module will result in lingering resources in your VPC.

