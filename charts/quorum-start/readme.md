```shell
// path d/Pharma/PharmaLedger-IMI/usecase-deployment/helm-charts

plugin : node-crypto-gen

helm plugin install ./plugins/quorum-tool/

helm quorum-tool -f ./charts/quorum-start/

helm install qn-0 ./charts/quorum-start -f ./charts/quorum-start/gen-values.yaml
// install 1 node with new crypto
// push genesis, validator key and enode to git

//clean up

helm delete qn-0
helm plugin uninstall quorum-tool

```
