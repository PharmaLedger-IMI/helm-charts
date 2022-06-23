# AWS Load Balancer Controller: Expose Peer-to-Peer (P2P) Service via AWS Network Load Balancer (NLB)

**Please read [this article](./../aws_nlb_problem_statement/README.md) first** which explains the major problem.

## Prerequisites

- [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)
- An AWS Elastic IP (EIP) which provides a static IPv4 address.
- Optional: External-DNS

## Example for AWS

Set helm values: In addition to other helm values, set these configuration values:

```yaml
service:
  p2p:
    type: LoadBalancer
    port: 30303
    annotations:
      # optional: Pretty DNS name
      # external-dns.alpha.kubernetes.io/hostname: "my-quorum.mycompany.com"
      service.beta.kubernetes.io/aws-load-balancer-name: "<todo: a nice for for the NLB>"
      service.beta.kubernetes.io/aws-load-balancer-eip-allocations: <todo: The EIP, e.g. eipallow-somevalue>
      service.beta.kubernetes.io/aws-load-balancer-subnets: <todo: a single public subnet, must be the same AZ as in nodeAffinity, e.g. pl-fra-public-eu-central-1a>
      service.beta.kubernetes.io/aws-load-balancer-type: "external"
      service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
      service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: ip
      service.beta.kubernetes.io/aws-load-balancer-ip-address-type: ipv4
      service.beta.kubernetes.io/aws-load-balancer-target-group-attributes: preserve_client_ip.enabled=true,deregistration_delay.timeout_seconds=120,deregistration_delay.connection_termination.enabled=true,stickiness.enabled=true,stickiness.type=source_ip
      service.beta.kubernetes.io/aws-load-balancer-healthcheck-healthy-threshold: "2"
      service.beta.kubernetes.io/aws-load-balancer-healthcheck-unhealthy-threshold: "2"
      service.beta.kubernetes.io/aws-load-balancer-attributes: load_balancing.cross_zone.enabled=false
    loadBalancerSourceRanges:
      - 1.2.3.4/32   # other Company A
      - 2.3.4.5/32   # other company B
      - 3.4.5.6/32   # other company C

affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: topology.kubernetes.io/zone
          operator: In
          values:
          - <todo: the same zone like the subnet for the NLB, e.g. eu-central-1a>

```
