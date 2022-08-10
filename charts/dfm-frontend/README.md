# dfm-frontend

![Version: 0.1.1](https://img.shields.io/badge/Version-0.1.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.16.0](https://img.shields.io/badge/AppVersion-1.16.0-informational?style=flat-square)

A Helm chart for Kubernetes

## Values

| Key | Type | Default                                                                                                                                                     | Description |
|-----|------|-------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| affinity | object | `{}`                                                                                                                                                        |  |
| autoscaling.enabled | bool | `false`                                                                                                                                                     |  |
| autoscaling.maxReplicas | int | `100`                                                                                                                                                       |  |
| autoscaling.minReplicas | int | `1`                                                                                                                                                         |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80`                                                                                                                                                        |  |
| fullnameOverride | string | `""`                                                                                                                                                        |  |
| image.pullPolicy | string | `"IfNotPresent"`                                                                                                                                            |  |
| image.repository | string | `"pharmaledger/dfm-frontend"`                                                                                                                               |  |
| image.sha | string | `"82e61a4ad16693ae14d60dbbd37a879b28dd9f71f9fd2fefa518e613fb099548"` <!-- # pragma: allowlist secret -->                                                    |  |
| image.tag | string | `"1.0.0"`                                                                                                                                                   |  |
| imagePullSecrets | list | `[]`                                                                                                                                                        |  |
| ingress.annotations | object | `{}`                                                                                                                                                        |  |
| ingress.className | string | `""`                                                                                                                                                        |  |
| ingress.enabled | bool | `false`                                                                                                                                                     |  |
| ingress.hosts[0].host | string | `"chart-example.local"`                                                                                                                                     |  |
| ingress.hosts[0].paths[0].path | string | `"/"`                                                                                                                                                       |  |
| ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"`                                                                                                                                  |  |
| ingress.tls | list | `[]`                                                                                                                                                        |  |
| livenessProbe | object | `{"failureThreshold":3,"initialDelaySeconds":10,"periodSeconds":10,"successThreshold":1,"tcpSocket":{"port":"http"},"timeoutSeconds":1}`                    | Liveness probe. Defaults to check if the server is listening. See [https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) |
| nameOverride | string | `""`                                                                                                                                                        |  |
| nodeSelector | object | `{}`                                                                                                                                                        |  |
| podAnnotations | object | `{}`                                                                                                                                                        |  |
| podSecurityContext | object | `{}`                                                                                                                                                        |  |
| readinessProbe | object | `{"failureThreshold":3,"httpGet":{"path":"/backoffice","port":"http"},"initialDelaySeconds":10,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":3}` | Readiness probe. Defaults to check if server can query data. See [https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) |
| replicaCount | int | `1`                                                                                                                                                         |  |
| resources | object | `{}`                                                                                                                                                        |  |
| securityContext | object | `{}`                                                                                                                                                        |  |
| service.port | int | `3004`                                                                                                                                                      |  |
| service.type | string | `"ClusterIP"`                                                                                                                                               |  |
| serviceAccount.annotations | object | `{}`                                                                                                                                                        |  |
| serviceAccount.create | bool | `false`                                                                                                                                                     |  |
| serviceAccount.name | string | `""`                                                                                                                                                        |  |
| tolerations | list | `[]`                                                                                                                                                        |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.8.1](https://github.com/norwoodj/helm-docs/releases/v1.8.1)
