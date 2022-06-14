# CHANGELOG

- From 0.6.x to 0.7.x
  - Replaced `config.smartContractAddress` and `config.smartContractInfoAbi` with `config.smartContractInfo`

- From 0.5.x to 0.6.x
  - Secret/Sensitive OrgAccountJson is not mounted as environment variable but as file what is good practice.
  - Support for CSI Secrets Driver to store OrgAccountJson e.g. on Azure Key Vault or AWS Secrets Manager instead of using a Kubernetes Secret.

- From 0.4.x to 0.5.x - Set "Good practice" values by default
  - SecurityContext (`podSecurityContext` and `securityContext` default to good practice values) enabled by default. Your Todo: Depending on your environment it is also recommended to set `podSecurityContext.seccompProfile`.
  - Resource limits and requests (`resources`) set to appropriate default values.
  - `image.pullPolicy` set to `Always` (before: `IfNotPresent`)

- From 0.3.x to 0.4.x
  - New SmartContract Abi set as default value ready for epi application v1.1.x or higher.
  - Either value `secrets.orgAccountJson` or `secrets.orgAccountJsonBase64` is always required. The OrgAccount data is not be provided by helm chart *smartcontract* anymore.

- From 0.2.x to 0.3.x
  - Value `config.rpcAddress` has changed from `http://quorum-member1.quorum:8545` to `http://quorum-validator1.quorum:8545`.
  This reflects the change of chart [standalone-quorum](https://github.com/PharmaLedger-IMI/helmchart-ethadapter/tree/standalone-quorum-0.2.0/charts/standalone-quorum#changelog) from version 0.1.x to 0.2.x where member nodes are not enabled by default.
