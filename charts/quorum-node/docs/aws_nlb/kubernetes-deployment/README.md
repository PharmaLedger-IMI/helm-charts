# Kubernetes YAML files for AWS Network Load Balancer and a pod deployment in a single availability zone

These YAML files deploy

1. A simple echo server onto a worker node in a **certain availability zone**
2. An internet-facing AWS Network Load Balancer (NLB) with
   1. a single **static/constant public IP address**
   2. allowing incoming traffic from dedicated client IP addresses only

## Prerequisites

1. AWS Load Balancer Controller version >= 2.2 deployed into Kubernetes cluster
2. Kubernetes nodes with label `topology.kubernetes.io/zone` set properly (usually set by default since Kubernetes 1.17). See [Kubernetes docs](https://kubernetes.io/docs/reference/labels-annotations-taints/#topologykubernetesiozone)
3. A free (not associated with any ENI) AWS Elastic IP address (EIP)

## How to

1. Open `service.yaml` and set values of these tags:
   1. `metadata` -> `annotations` -> `service.beta.kubernetes.io/aws-load-balancer-eip-allocations` - *AllocationID of EIP*, e.g. `eipalloc-01234567890abcdef`
   2. `metadata` -> `annotations` -> `service.beta.kubernetes.io/aws-load-balancer-subnets` - *Name or ID of the **public subnet*** for NLB, e.g. `public-eu-west-1a` or `subnet-01234567890abcdef`. **Note:** The subnet **SHOULD** be located in the same availability zone as zone affinity of the deployment (see `affinity` below).
   3. `metadata` -> `annotations` -> `service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled` - Set to `false` if subnet of NLB and zone affinity of the deployment are within the same availability zone (recommended), else set to `true`.
   4. `spec` -> `loadBalancerSourceRanges` - Edit/add the valid client IP CIDR range(s)
2. Open `deployment.yaml` and set value of this tags:
   1. `affinity` -> `nodeAffinity` -> `requiredDuringSchedulingIgnoredDuringExecution` -> `nodeSelectorTerms[0]` -> `matchExpressions[0]` -> `key` -> `values[0]` - The *name of the AWS availability zone* of the worker node for the pod, e.g. `eu-west-1a`
3. Install via kubectl `kubectl apply [--namespace=default] -f .`
4. See the output of the echo server by either
   1. Open a browser window `http://IP_ADRESS` or `http://NLB_DNS_NAME`
   2. or `curl http://IP_ADRESS` or `curl http://NLB_DNS_NAME`

## Cleanup

```bash
kubectl delete [--namespace=default] -f .
```

## Links

- [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/guide/service/annotations/)
- [Pod affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#an-example-of-a-pod-that-uses-pod-affinity)
- [Kubernetes Node Labels](https://kubernetes.io/docs/reference/labels-annotations-taints/)
- [AWS Network Load Balancer - Elastic IP attachment](https://aws.amazon.com/premiumsupport/knowledge-center/elb-attach-elastic-ip-to-public-nlb/)
- [AWS Network Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/introduction.html)
