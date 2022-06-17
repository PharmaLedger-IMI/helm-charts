# AWS Load Balancer Controller: Expose Service via Ingress

**Please Note** There should be no need to expose the EthAdapter to the public internet. The EthAdapter does not (as of June 2022) provide any kind of authentication mechanism, therefore ingress traffic to ethadapter should be restricted to (epi) application only!

This sample demonstrates how you can use AWS Load Balancer Controller for exposing the service, but please note: This is still not recommended!

## Cluster prerequisites

- [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)

## Example for AWS

1. Enable ingress
2. Add *host*, *path* *`/*`* and *pathType* `ImplementationSpecific`
3. Add annotations for AWS LB Controller
4. A SSL certificate at AWS Certificate Manager (either for the hostname, here `ethadapter.mydomain.com` or wildcard `*.mydomain.com`)
5. Set helm values: In addition to other helm values, set these configuration values:

    ```yaml
    ingress:
      enabled: true
      # Let AWS LB Controller handle the ingress (default className is alb)
      # Note: Use className instead of annotation 'kubernetes.io/ingress.class' which is deprecated since 1.18
      # For Kubernetes >= 1.18 it is required to have an existing IngressClass object.
      # See: https://kubernetes.io/docs/concepts/services-networking/ingress/#deprecated-annotation
      className: alb
      hosts:
        - host: ethadapter.mydomain.com
          # Path must be /* for ALB to match all paths
          paths:
            - path: /*
              pathType: ImplementationSpecific
      # For full list of annotations for AWS LB Controller, see https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.3/guide/ingress/annotations/
      annotations:
        # The ARN of the existing SSL Certificate at AWS Certificate Manager
        alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:REGION:ACCOUNT_ID:certificate/CERTIFICATE_ID
        # The name of the ALB group, can be used to configure a single ALB by multiple ingress objects
        alb.ingress.kubernetes.io/group.name: default
        # Specifies the HTTP path when performing health check on targets.
        alb.ingress.kubernetes.io/healthcheck-path: /check
        # Specifies the port used when performing health check on targets.
        alb.ingress.kubernetes.io/healthcheck-port: traffic-port
        # Specifies the HTTP status code that should be expected when doing health checks against the specified health check path.
        alb.ingress.kubernetes.io/success-codes: "200"
        # Listen on HTTPS protocol at port 3000 at the ALB
        alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS":3000}]'
        # Allow access from a specific IP address only, e.g. from the NAT Gateway of your EPI Cluster
        alb.ingress.kubernetes.io/inbound-cidrs: 8.8.8.8/32
        # Use internet facing
        alb.ingress.kubernetes.io/scheme: internet-facing
        # Use most current (as of Dec 2021) encryption ciphers
        alb.ingress.kubernetes.io/ssl-policy: ELBSecurityPolicy-TLS-1-2-Ext-2018-06
        # Use target type IP which is the case if the service type is ClusterIP
        alb.ingress.kubernetes.io/target-type: ip

    ```
