# blockchain-explorer

![Version: 0.1.2](https://img.shields.io/badge/Version-0.1.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.0](https://img.shields.io/badge/AppVersion-1.0.0-informational?style=flat-square)

A Helm chart for Kubernetes

## Requirements

- [helm 3](https://helm.sh/docs/intro/install/)
- These mandatory configuration values:
  - quorumConfig - Configure the connection to your quorum node
  - quorumEnvProduction - Configure environment details such as authentication services (e.g. Azure AD)

Additional remarks:

- The image is currently provided via DockerHub without any vulnerability scanning - it is best practice to pull the image to any scanning solution before using it
- The image is currently build in GitHub based on a manual trigger as the Quorum Explorer repository (https://github.com/ConsenSys/quorum-explorer) does not provide any versioning yet

## Usage

- [Here](./README.md#values) is a full list of all configuration values.
- The [values.yaml file](./values.yaml) shows the raw view of all configuration values.

## Changelog

- Initial version 0.1.2
  - For initial beta use - application is still in development by ConsenSys

## Helm Lifecycle and Kubernetes Resources Lifetime

This helm chart uses Helm [hooks](https://helm.sh/docs/topics/charts_hooks/) in order to install, upgrade and manage the application and its resources.

### Expose Service via Load Balancer

In order to expose the service **directly** by an **own dedicated** Load Balancer, just **add** `service.type` with value `LoadBalancer` to your config file (in order to override the default value which is `ClusterIP`).

**Please note:** At AWS using `service.type` = `LoadBalancer` is not recommended any more, as it creates a Classic Load Balancer. Use [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.3/) with an ingress instead. A full sample is provided later in the docs. Using an Application Load Balancer (managed by AWS LB Controller) increases security (e.g. by using a Web Application Firewall for your http based traffic) and provides more features like hostname, pathname routing or built-in authentication mechanism via OIDC or AWS Cognito.

Configuration file *my-config.yaml*

```yaml
services:
  app:
    type: LoadBalancer
  api:
    type: LoadBalancer
  swagger:
    type: LoadBalancer

config:
  # ... config section keys and values ...
```

There are more configuration options available like customizing the port and configuring the Load Balancer via annotations (e.g. for configuring SSL Listener).

**Also note:** Annotations are very specific to your environment/cloud provider, see [Kubernetes Service Reference](https://kubernetes.io/docs/concepts/services-networking/service/#ssl-support-on-aws) for more information. For Azure, take a look [here](https://kubernetes-sigs.github.io/cloud-provider-azure/topics/loadbalancer/#loadbalancer-annotations).

Sample for AWS (SSL and listening on port 1234 instead 80 which is the default):

```yaml
service:
  app:
    type: LoadBalancer
    port: 80
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-ssl-cert: arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012
      service.beta.kubernetes.io/aws-load-balancer-backend-protocol: http
      service.beta.kubernetes.io/aws-load-balancer-ssl-ports: "1234"
      # https://docs.aws.amazon.com/de_de/elasticloadbalancing/latest/classic/elb-security-policy-table.html
      service.beta.kubernetes.io/aws-load-balancer-ssl-negotiation-policy: "ELBSecurityPolicy-TLS-1-2-2017-01"

# further config
```

### AWS Load Balancer Controler: Expose Service via Ingress

Note: You need the [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/) installed and configured properly.

1. Enable ingress
2. Add *host*, *path* *`/*`* and *pathType* `ImplementationSpecific`
3. Add annotations for AWS LB Controller
4. A SSL certificate at AWS Certificate Manager (either for the hostname, here `epi.mydomain.com` or wildcard `*.mydomain.com`)

Configuration file *my-config.yaml*

```yaml
ingress:
  app:
    # -- Whether to create ingress or not.
    # Note: For ingress an Ingress Controller (e.g. AWS LB Controller, NGINX Ingress Controller, Traefik, ...) is required and service.type should be ClusterIP or NodePort depending on your configuration
    enabled: false
    # -- The className specifies the IngressClass object which is responsible for that class.
    # Note for Kubernetes >= 1.18 it is required to have an existing IngressClass object.
    # If IngressClass object does not exists, omit className and add the deprecated annotation 'kubernetes.io/ingress.class' instead.
    # For Kubernetes < 1.18 either use className or annotation 'kubernetes.io/ingress.class'.
    # See https://kubernetes.io/docs/concepts/services-networking/ingress/#ingress-class
    className: ""
    # -- Ingress annotations.
    # For AWS LB Controller, see [https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.3/guide/ingress/annotations/](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.3/guide/ingress/annotations/)
    # For Azure Application Gateway Ingress Controller, see [https://azure.github.io/application-gateway-kubernetes-ingress/annotations/](https://azure.github.io/application-gateway-kubernetes-ingress/annotations/)
    # For NGINX Ingress Controller, see [https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/)
    # For Traefik Ingress Controller, see [https://doc.traefik.io/traefik/routing/providers/kubernetes-ingress/#annotations](https://doc.traefik.io/traefik/routing/providers/kubernetes-ingress/#annotations)
    annotations: {}
      # kubernetes.io/ingress.class: nginx
      # kubernetes.io/tls-acme: "true"
    # -- A list of hostnames and path(s) to listen at the Ingress Controller
    hosts:
      -
        # -- The FQDN/hostname
        host: explorer.some-pharma-company.com
        paths:
          -
            # -- The Ingress Path. See [https://kubernetes.io/docs/concepts/services-networking/ingress/#examples](https://kubernetes.io/docs/concepts/services-networking/ingress/#examples)
            # Note: For Ingress Controllers like AWS LB Controller see their specific documentation.
            path: /
            # -- The type of path. This value is required since Kubernetes 1.18.
            # For Ingress Controllers like AWS LB Controller or Traefik it is usually required to set its value to ImplementationSpecific
            # See [https://kubernetes.io/docs/concepts/services-networking/ingress/#path-types](https://kubernetes.io/docs/concepts/services-networking/ingress/#path-types)
            # and [https://kubernetes.io/blog/2020/04/02/improvements-to-the-ingress-api-in-kubernetes-1.18/](https://kubernetes.io/blog/2020/04/02/improvements-to-the-ingress-api-in-kubernetes-1.18/)
            pathType: ImplementationSpecific
    tls: []
    #  - secretName: chart-example-tls
    #    hosts:
    #      - chart-example.local

config:
  # ... config section keys and values ...
```

### Additional helm options

Run `helm upgrade --helm` for full list of options.

1. Install to other namespace

    You can install into other namespace than `default` by setting the `--namespace` parameter, e.g.

    ```bash
    helm upgrade my-release-name pharmaledger-imi/blockchain-explorer --version=0.1.2 \
        --install \
        --namespace=my-namespace \
        --values my-config.yaml \
    ```

2. Wait until installation has finished successfully and the deployment is up and running.

    Provide the `--wait` argument and time to wait (default is 5 minutes) via `--timeout`

    ```bash
    helm upgrade my-release-name pharmaledger-imi/blockchain-explorer --version=0.1.2 \
        --install \
        --wait --timeout=600s \
        --values my-config.yaml \
    ```

### Potential issues

1. `Error: admission webhook "vingress.elbv2.k8s.aws" denied the request: invalid ingress class: IngressClass.networking.k8s.io "alb" not found`

    **Description:** This error only applies to Kubernetes >= 1.18 and indicates that no matching *IngressClass* object was found.

    **Solution:** Either declare an appropriate IngressClass or omit *className* and add annotation `kubernetes.io/ingress.class`

    Further information:

     - [Kubernetes IngressClass](https://kubernetes.io/docs/concepts/services-networking/ingress/#ingress-class)
     - [AWS Load Balancer controller documentation](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.3/guide/ingress/ingress_class/)

## Helm Unittesting

[helm-unittest](https://github.com/quintush/helm-unittest) is being used for testing the output of the helm chart.
Tests can be found in [tests](./tests)

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `100` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `"Always"` |  |
| image.repository | string | `"lukasosterheider/quorum-explorer"` |  |
| image.tag | string | `"latest"` |  |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `""` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0].host | string | `"chart-example.local"` |  |
| ingress.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| ingress.tls | list | `[]` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| quorumConfig | string | `"{\n  \"algorithm\": \"qbft\",\n  \"nodes\": [\n    {\n      \"name\": \"rpcnode\",\n      \"client\": \"goquorum\",\n      \"rpcUrl\": \"http://quorum-node-0-rpc.epi-poc-quorum:8545\",\n      \"privateTxUrl\": \"\"\n    }\n  ]\n}"` |  |
| quorumEnvProduction | string | `"QE_BASEPATH=\"/explorer\"\nQE_CONFIG_PATH=\"/app/config.json\"\nNODE_ENV=production\n\nDISABLE_AUTH=true\n\nNEXTAUTH_URL=http://localhost:25000\nNEXTAUTH_URL_INTERNAL=http://localhost:25000\nNEXTAUTH_SECRET=\n# To generate NEXTAUTH_SECRET: `openssl rand -hex 32` or go to https://generate-secret.now.sh/32\n\nlocal_username=\nlocal_password=\n\nGITHUB_ID=\nGITHUB_SECRET=\n\nAUTH0_ID=\nAUTH0_SECRET=\nAUTH0_DOMAIN=\n\nFACEBOOK_ID=\nFACEBOOK_SECRET=\n\nGOOGLE_ID=\nGOOGLE_SECRET=\n\nTWITTER_ID=\nTWITTER_SECRET=\n\nGITLAB_CLIENT_ID=\nGITLAB_CLIENT_SECRET=\n\nAZURE_AD_CLIENT_ID=\nAZURE_AD_CLIENT_SECRET=\nAZURE_AD_TENANT_ID=\n\nATLASSIAN_CLIENT_ID=\nATLASSIAN_CLIENT_SECRET=\n\nCOGNITO_CLIENT_ID=\nCOGNITO_CLIENT_SECRET=\nCOGNITO_ISSUER=\n\nOKTA_CLIENT_ID=\nOKTA_CLIENT_SECRET=\nOKTA_ISSUER=\n\nSLACK_CLIENT_ID=\nSLACK_CLIENT_SECRET="` |  |
| replicaCount | int | `1` |  |
| resources | object | `{}` |  |
| securityContext | object | `{}` |  |
| service.port | int | `80` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| tolerations | list | `[]` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.8.1](https://github.com/norwoodj/helm-docs/releases/v1.8.1)