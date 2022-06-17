# Expose Service via Load Balancer

**Please Note** There should be no need to expose the EthAdapter to the public internet. The EthAdapter does not (as of June 2022) provide any kind of authentication mechanism, therefore ingress traffic to ethadapter should be restricted to (epi) application only!

This sample demonstrates how you can use a Kubernetes service of type *LoadBalancer* for exposing the service, but please note: This is still not recommended!

## Cluster prerequisites

- none (built-in)

## Overall

In order to expose the service **directly** by an **own dedicated** Load Balancer, just **add** `service.type` with value `LoadBalancer` to your config file (in order to override the default value which is `ClusterIP`).

In addition to other helm values, set these configuration values:

```yaml
service:
  type: LoadBalancer
```

There are more configuration options available like customizing the port and configuring the Load Balancer via annotations (e.g. for configuring SSL Listener). Annotations are very specific to your environment/cloud provider, see [Kubernetes Service Reference](https://kubernetes.io/docs/concepts/services-networking/service/#ssl-support-on-aws) for more information. For Azure, take a look [here](https://kubernetes-sigs.github.io/cloud-provider-azure/topics/loadbalancer/#loadbalancer-annotations).

## AWS

**Note:** At AWS using `service.type` = `LoadBalancer` is not recommended any more, as it creates a Classic Load Balancer.
Use [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/) with an ingress instead.
A full sample is provided [here](../aws_lb_controller_ingress/README.md).
Using an Application Load Balancer (managed by AWS LB Controller) increases security (e.g. by using a Web Application Firewall for your http based traffic)
and provides more features like hostname, pathname routing or built-in authentication mechanism via OIDC or AWS Cognito.

Sample for AWS (SSL and listening on port 4567 instead 3000 which is the default):

```yaml
service:
  type: LoadBalancer
  port: 4567
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-ssl-cert: arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012
    service.beta.kubernetes.io/aws-load-balancer-backend-protocol: http
    service.beta.kubernetes.io/aws-load-balancer-ssl-ports: "4567"
    # https://docs.aws.amazon.com/de_de/elasticloadbalancing/latest/classic/elb-security-policy-table.html
    service.beta.kubernetes.io/aws-load-balancer-ssl-negotiation-policy: "ELBSecurityPolicy-TLS-1-2-2017-01"

```
