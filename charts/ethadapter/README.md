# ethadapter

![Version: 0.7.8](https://img.shields.io/badge/Version-0.7.8-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.2](https://img.shields.io/badge/AppVersion-1.0.2-informational?style=flat-square)

A Helm chart for Pharma Ledger Ethereum Adapter Service

## Requirements

- [helm 3](https://helm.sh/docs/intro/install/)
- At least these input parameters for helm:

  | Configuration<br/>value | Description | Sandbox | Non-Sandbox<br/>connected blockchain |
  |-------------------------|:-----------:|:-------:|:------------------------------------:|
  | `config.rpcAddress`     | Address of<br/>Quorum node | **Not required** if helm chart<br/>*standalone-quorum* is used | **Required** |
  | `config.smartContractInfo` | Info for SmartContract:<br/>Anchor address and <br/>Abi | **Not required** if helm chart<br/>*smartcontract* is used<br/>(autoconfiguration) | **Required** |
  | `secrets.orgAccountJson`<br/>**or**<br/>`secrets.orgAccountJsonBase64` | ETH account and<br/>private key | **Required**<br/>(only if<br/>`secretProviderClass.enabled: false`) | **Required**(* see note below)<br/>(only if<br/>`secretProviderClass.enabled: false`)  |

  <!-- # pragma: allowlist nextline secret -->
  **Note about ETH account:**(*) For Sandbox environment (helm chart *standalone-quorum*) use `{"address": "0xb5ced4530d6ccbb31b2b542fd9b4558b52296784", "privateKey": "0x6b93a268f68239d321981125ecf24488920c6b3d900043d56fef66adb776abd5"}`

## Changelog

See [Changelog](./CHANGELOG.md) for significant changes!

## Usage

- [Here](./README.md#values) is a full list of all configuration values.
- The [values.yaml file](./values.yaml) shows the raw view of all configuration values.
- [**FULL SAMPLE**](./docs/full_sample/README.md) with multiple features combined.

## Features

- Security by default:
  - SecurityContext
  - Non-root user
  - readonly filesystem
- Option to mount sensitive/secret via *CSI Secrets Driver* from a vault solution like AWS Secrets Manager, Azure Key Vault, GCP Secrets Manager or HashiCorp Vault instead of using *Kubernetes Secret*. See [here](./docs/secret_provider_class/README.md) for details.
- Option to provide `extraResources` like Network Policies. See [here](./docs/network_policies/README.md) for details.

## How it works

This helm chart creates a ConfigMap and Secret (or mount orgAccountJson via CSI Secrets Driver if `secretProviderClass.enabled: true`) with required configuration values.

- The ConfigMap is being used to store a) address of Quorum Node, b) address of Smart Contract anchoring and c) Abi of the SmartContract.
- The Secret (if `secretProviderClass.enabled: false`) contains the ETH Account and its private key. Autoconfiguration: In case you do not explictly provide `config.smartContractInfo` helm will try to read this value from a pre-existing ConfigMap (provided by helm chart *smartcontract*) in context of the user executing helm.
- If you want to store the secret data outside Kubernetes (`secretProviderClass.enabled: true`) and mount it as file, see sample for *CSI Secrets Driver* below.

**By default, this helm chart installs the Ethereum Adapter Service at an internal ClusterIP Service listening at port 3000.
This is to prevent exposing the service to the internet by accident!**

![How it works](./docs/ethadapter.drawio.png)

## Installing the Chart

**Note:** It is recommended to put non-sensitive configuration values in an configuration file and pass sensitive/secret values via commandline.

### Sandbox installation - Auto-configure Smart Contract Info

Install the chart with the release name `ethadapter` in namespace `ethadapter` and read SmartContract Info from pre-existing ConfigMap created by helm chart *smartcontract*.

```bash
helm upgrade --install ethadapter pharmaledger-imi/ethadapter --version=0.7.8 \
  --install \
  --set secrets.orgAccountJson="\{\"address\": \"0xb5ced4530d6ccbb31b2b542fd9b4558b52296784\"\, \"privateKey\": \"0x6b93a268f68239d321981125ecf24488920c6b3d900043d56fef66adb776abd5\"\}"
  --wait \
  --timeout 10m

```

### Non-Sandbox installation - Provide required values

1. Create configuration file, e.g. *my-config.yaml*

    ```yaml
    config:
      rpcAddress: "rpcAddress_value"
      smartContractInfo: |-
        {
          "address": "smartContractAddress_value",
          "abi": "[{\"inputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"internalType\":\"bool\",\"name\":\"str\",\"type\":\"bool\"}],\"name\":\"BoolResult\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"internalType\":\"bytes1\",\"name\":\"str\",\"type\":\"bytes1\"}],\"name\":\"Bytes1Result\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"internalType\":\"bytes32\",\"name\":\"str\",\"type\":\"bytes32\"}],\"name\":\"Bytes32Result\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"uint256\",\"name\":\"statusCode\",\"type\":\"uint256\"}],\"name\":\"InvokeStatus\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"internalType\":\"bytes\",\"name\":\"str\",\"type\":\"bytes\"}],\"name\":\"Result\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"internalType\":\"string[2]\",\"name\":\"str\",\"type\":\"string[2]\"}],\"name\":\"StringArray2Result\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"internalType\":\"string[]\",\"name\":\"str\",\"type\":\"string[]\"}],\"name\":\"StringArrayResult\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"internalType\":\"string\",\"name\":\"str\",\"type\":\"string\"}],\"name\":\"StringResult\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"str\",\"type\":\"uint256\"}],\"name\":\"UIntResult\",\"type\":\"event\"},{\"inputs\":[{\"internalType\":\"string\",\"name\":\"anchorId\",\"type\":\"string\"},{\"internalType\":\"string\",\"name\":\"newAnchorValue\",\"type\":\"string\"},{\"internalType\":\"uint8\",\"name\":\"v\",\"type\":\"uint8\"}],\"name\":\"createAnchor\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"string\",\"name\":\"anchorId\",\"type\":\"string\"},{\"internalType\":\"string\",\"name\":\"newAnchorValue\",\"type\":\"string\"},{\"internalType\":\"uint8\",\"name\":\"v\",\"type\":\"uint8\"}],\"name\":\"appendAnchor\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"string\",\"name\":\"anchorId\",\"type\":\"string\"}],\"name\":\"getAllVersions\",\"outputs\":[{\"internalType\":\"string[]\",\"name\":\"\",\"type\":\"string[]\"}],\"stateMutability\":\"view\",\"type\":\"function\",\"constant\":true},{\"inputs\":[{\"internalType\":\"string\",\"name\":\"anchorId\",\"type\":\"string\"}],\"name\":\"getLastVersion\",\"outputs\":[{\"internalType\":\"string\",\"name\":\"\",\"type\":\"string\"}],\"stateMutability\":\"view\",\"type\":\"function\",\"constant\":true},{\"inputs\":[{\"internalType\":\"string[]\",\"name\":\"anchors\",\"type\":\"string[]\"}],\"name\":\"createOrUpdateMultipleAnchors\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"from\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"limit\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"maxSize\",\"type\":\"uint256\"}],\"name\":\"dumpAnchors\",\"outputs\":[{\"components\":[{\"internalType\":\"string\",\"name\":\"anchorId\",\"type\":\"string\"},{\"internalType\":\"string[]\",\"name\":\"anchorValues\",\"type\":\"string[]\"}],\"internalType\":\"struct Anchoring.Anchor[]\",\"name\":\"\",\"type\":\"tuple[]\"}],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"totalNumberOfAnchors\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"hash\",\"type\":\"bytes32\"},{\"internalType\":\"bytes\",\"name\":\"signature\",\"type\":\"bytes\"},{\"internalType\":\"uint8\",\"name\":\"v\",\"type\":\"uint8\"}],\"name\":\"recover\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"nonpayable\",\"type\":\"function\"}]"
        }
    ```

2. Install via helm to namespace `ethadapter` either by passing sensitive *Org Account JSON* value in JSON format as escaped string

    ```bash
    helm upgrade --install ethadapter pharmaledger-imi/ethadapter --version=0.7.8 \
        --wait \
        --timeout 10m \
        --values my-config.yaml \
        --set-string secrets.orgAccountJson="\{ \"address\": \"0xabcdef1234567890\" \, \"privateKey\": \"0x1234567890abcdef\" \}"

    ```

3. or pass sensitive *Org Account JSON* value in JSON format as base64 encoded string

    ```bash
    helm upgrade --install ethadapter pharmaledger-imi/ethadapter --version=0.7.8 \
        --wait \
        --timeout 10m \
        --values my-config.yaml \
        --set-string secrets.orgAccountJsonBase64="eyAia2V5IjogInZhbHVlIiB9"

    ```

## Further configuration options

- [Mount Secrets from Vault Solution via Secrets Store CSI Driver](./docs/secret_provider_class/README.md)
- [Network Policies](./docs/network_policies/README.md)
- [Expose Service via Load Balancer](./docs/load_balancer/README.md)
- [AWS Load Balancer Controller: Expose Service via Ingress](./docs/aws_lb_controller_ingress/README.md)

## Uninstalling the Chart

To uninstall/delete the `ethadapter` deployment:

```bash
helm delete ethadapter \
  --namespace=ethadapter

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

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| tgip-work |  | <https://github.com/tgip-work> |

## Values

*Note:* Please scroll horizontally to show more columns (e.g. description)!

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity for scheduling a pod. See [https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/) |
| autoscaling.enabled | bool | `false` | Whether to enable horizontal pod autoscaling or not. See [https://kubernetes.io/de/docs/tasks/run-application/horizontal-pod-autoscale/](https://kubernetes.io/de/docs/tasks/run-application/horizontal-pod-autoscale/) |
| autoscaling.maxReplicas | int | `100` | The maximum number of replicas in case autoscaling is enabled. |
| autoscaling.minReplicas | int | `1` | The minimum number of replicas in case autoscaling is enabled. |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | The CPU utilization in percentage as a target for autoscaling. |
| config.rpcAddress | string | `"http://quorum-validator1.quorum:8545"` | URL of the Quorum node |
| config.smartContractInfo | string | `"{\n  \"address\": \"\",\n  \"abi\": \"\"\n}"` | Smart Contract Info. A JSON object with these two keys: "address" and "abi" If not set/empty, tries to get value from ConfigMap '.config.smartContractInfoConfigMapName' with key '.config.smartContractInfoConfigMapKey' |
| config.smartContractInfoConfigMapKey | string | `"info"` | The key of the SmartContractInfo in the existing ConfigMap in case 'smartContractInfo' is not explictly defined. |
| config.smartContractInfoConfigMapName | string | `"smartcontractinfo"` | The name of the existing ConfigMap to look for in case value 'smartContractInfo' is not defined. |
| extraResources | string | `nil` | An array of extra resources that will be deployed. This is useful e.g. for NetworkPolices |
| fullnameOverride | string | `""` | fullnameOverride completely replaces the generated name. From [https://stackoverflow.com/questions/63838705/what-is-the-difference-between-fullnameoverride-and-nameoverride-in-helm](https://stackoverflow.com/questions/63838705/what-is-the-difference-between-fullnameoverride-and-nameoverride-in-helm) |
| image.pullPolicy | string | `"Always"` | Image Pull Policy |
| image.repository | string | `"pharmaledger/ethadapter"` | The repository of the container image |
| image.sha | string | `"e387f4b292fff25f6d7fa1792ec586bf46cab31265a84136561c469accd81b06"` | sha256 digest of the image. Do not add the prefix "@sha256:" Default to image digest for version 1.0.2 <!-- # pragma: allowlist secret --> |
| image.tag | string | `"1.0.2"` | Overrides the image tag whose default is the chart appVersion. |
| imagePullSecrets | list | `[]` | Secret(s) for pulling an container image from a private registry. See [https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/) |
| ingress.annotations | object | `{}` | Ingress annotations. For AWS LB Controller, see [https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.3/guide/ingress/annotations/](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.3/guide/ingress/annotations/) For Azure Application Gateway Ingress Controller, see [https://azure.github.io/application-gateway-kubernetes-ingress/annotations/](https://azure.github.io/application-gateway-kubernetes-ingress/annotations/) For NGINX Ingress Controller, see [https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/) For Traefik Ingress Controller, see [https://doc.traefik.io/traefik/routing/providers/kubernetes-ingress/#annotations](https://doc.traefik.io/traefik/routing/providers/kubernetes-ingress/#annotations) |
| ingress.className | string | `""` | The className specifies the IngressClass object which is responsible for that class. Note for Kubernetes >= 1.18 it is required to have an existing IngressClass object. If IngressClass object does not exists, omit className and add the deprecated annotation 'kubernetes.io/ingress.class' instead. For Kubernetes < 1.18 either use className or annotation 'kubernetes.io/ingress.class'. See https://kubernetes.io/docs/concepts/services-networking/ingress/#ingress-class |
| ingress.enabled | bool | `false` | Whether to create ingress or not. Note: For ingress an Ingress Controller (e.g. AWS LB Controller, NGINX Ingress Controller, Traefik, ...) is required and service.type should be ClusterIP or NodePort depending on your configuration |
| ingress.hosts | list | `[{"host":"ethadapter.some-pharma-company.com","paths":[{"path":"/","pathType":"ImplementationSpecific"}]}]` | A list of hostnames and path(s) to listen at the Ingress Controller |
| ingress.hosts[0].host | string | `"ethadapter.some-pharma-company.com"` | The FQDN/hostname |
| ingress.hosts[0].paths[0].path | string | `"/"` | The Ingress Path. See [https://kubernetes.io/docs/concepts/services-networking/ingress/#examples](https://kubernetes.io/docs/concepts/services-networking/ingress/#examples) Note: For Ingress Controllers like AWS LB Controller see their specific documentation. |
| ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` | The type of path. This value is required since Kubernetes 1.18. For Ingress Controllers like AWS LB Controller or Traefik it is usually required to set its value to ImplementationSpecific See [https://kubernetes.io/docs/concepts/services-networking/ingress/#path-types](https://kubernetes.io/docs/concepts/services-networking/ingress/#path-types) and [https://kubernetes.io/blog/2020/04/02/improvements-to-the-ingress-api-in-kubernetes-1.18/](https://kubernetes.io/blog/2020/04/02/improvements-to-the-ingress-api-in-kubernetes-1.18/) |
| ingress.tls | list | `[]` |  |
| livenessProbe | object | `{"failureThreshold":3,"initialDelaySeconds":10,"periodSeconds":10,"successThreshold":1,"tcpSocket":{"port":"http"},"timeoutSeconds":1}` | Liveness probe. Defaults to check if the server is listening. See [https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) |
| nameOverride | string | `""` | nameOverride replaces the name of the chart in the Chart.yaml file, when this is used to construct Kubernetes object names. From [https://stackoverflow.com/questions/63838705/what-is-the-difference-between-fullnameoverride-and-nameoverride-in-helm](https://stackoverflow.com/questions/63838705/what-is-the-difference-between-fullnameoverride-and-nameoverride-in-helm) |
| namespaceOverride | string | `""` | Override the deployment namespace. Very useful for multi-namespace deployments in combined charts |
| nodeSelector | object | `{}` | Node Selectors in order to assign pods to certain nodes. See [https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/) |
| podAnnotations | object | `{}` | Annotations added to the pod |
| podSecurityContext | object | `{"fsGroup":65534,"runAsGroup":65534,"runAsUser":65534}` | Security Context for the pod. See [https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod) |
| readinessProbe | object | `{"failureThreshold":3,"httpGet":{"path":"/totalNumberOfAnchors/","port":"http"},"initialDelaySeconds":10,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":3}` | Readiness probe. Defaults to check if server can query data. See [https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) |
| replicaCount | int | `1` | The number of replicas if autoscaling is false |
| resources | object | `{"limits":{"cpu":"100m","memory":"128Mi"},"requests":{"cpu":"5m","memory":"64Mi"}}` | Resource constraints for a pod |
| secretProviderClass.apiVersion | string | `"secrets-store.csi.x-k8s.io/v1"` | API Version of the SecretProviderClass |
| secretProviderClass.enabled | bool | `false` | Whether to use CSI Secrets Store (e.g. Azure Key Vault) instead of "traditional" Kubernetes Secret. |
| secretProviderClass.spec | object | `{}` | Spec for the SecretProviderClass. Note: The orgAccountJson must be mounted as objectAlias orgAccountJson |
| secrets.orgAccountJson | string | `""` | Org Account in JSON format. This value must be set or orgAccountJsonBase64. |
| secrets.orgAccountJsonBase64 | string | `""` | Org Account in JSON format base64 encoded. This value must be set or orgAccountJson |
| securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsGroup":65534,"runAsNonRoot":true,"runAsUser":65534}` | Security Context for the container. See [https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-container](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-container) |
| service.annotations | object | `{}` | Annotations for the service. See AWS, see [https://kubernetes.io/docs/concepts/services-networking/service/#ssl-support-on-aws](https://kubernetes.io/docs/concepts/services-networking/service/#ssl-support-on-aws) For Azure, see [https://kubernetes-sigs.github.io/cloud-provider-azure/topics/loadbalancer/#loadbalancer-annotations](https://kubernetes-sigs.github.io/cloud-provider-azure/topics/loadbalancer/#loadbalancer-annotations) |
| service.loadBalancerIP | string | `""` | A static IP address for the LoadBalancer if type is LoadBalancer. Note: This only applies to certain Cloud providers like Google or [Azure](https://docs.microsoft.com/en-us/azure/aks/static-ip). [https://kubernetes.io/docs/concepts/services-networking/service/#type-loadbalancer](https://kubernetes.io/docs/concepts/services-networking/service/#type-loadbalancer). |
| service.loadBalancerSourceRanges | string | `nil` | A list of CIDR ranges to whitelist for ingress traffic to the RPC service if type is LoadBalancer. If list is empty, Kubernetes allows traffic from 0.0.0.0/0 to the Node Security Group(s) |
| service.port | int | `3000` | Port where the service will be exposed |
| service.type | string | `"ClusterIP"` | Either ClusterIP, NodePort or LoadBalancer. See [https://kubernetes.io/docs/concepts/services-networking/service/](https://kubernetes.io/docs/concepts/services-networking/service/) |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.automountServiceAccountToken | bool | `false` | Whether automounting API credentials for a service account is enabled or not. See [https://docs.bridgecrew.io/docs/bc_k8s_35](https://docs.bridgecrew.io/docs/bc_k8s_35) |
| serviceAccount.create | bool | `false` | Specifies whether a service account should be created. Must be true if secretProviderClass.enabled is true |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| smart_contract_shared_configuration | object | `{"network_name":"","read_write_token":"","repository_name":"","smartContractInfoName":"anchoring.json"}` | The location of the smart contract info uploaded when the smart contract was deployed |
| smart_contract_shared_configuration.network_name | string | `""` | name of the network, eg. ePI, csc, iot, etc. |
| smart_contract_shared_configuration.read_write_token | string | `""` | github access token |
| smart_contract_shared_configuration.repository_name | string | `""` | username/shared-repository |
| smart_contract_shared_configuration.smartContractInfoName | string | `"anchoring.json"` | smart contract file name |
| tolerations | list | `[]` | Tolerations for scheduling a pod. See [https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.8.1](https://github.com/norwoodj/helm-docs/releases/v1.8.1)
