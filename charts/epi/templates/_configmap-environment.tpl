{{- /*
Template for Configmap.

Arguments to be passed are 
- $ (index 0)
- . (index 1)
- suffix (index 2)
- dictionary (index 3) for annotations used for defining helm hooks.

See https://blog.flant.com/advanced-helm-templating/
*/}}
{{- define "epi.configmap-environment" -}}
{{- $ := index . 0 }}
{{- $suffix := index . 2 }}
{{- $annotations := index . 3 }}
{{- with index . 1 }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "epi.fullname" . }}-environment{{ $suffix | default "" }}
  {{- with $annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  labels:
    {{- include "epi.labels" . | nindent 4 }}
data:
  # https://github.com/PharmaLedger-IMI/epi-workspace/blob/v1.3.0/trust-loader-config/demiurge-wallet/loader/environment.js
  demiurge-environment.js: |-
    export default {
      "appName": "Demiurge",
      "vault": "server",
      "agent": "browser",
      "system":   "any",
      "browser":  "any",
      "mode": {{ .Values.config.demiurgeMode | quote }},
      "vaultDomain":  {{ required "config.vaultDomain must be set" .Values.config.vaultDomain | quote }},
      "didDomain":  {{ required "config.vaultDomain must be set" .Values.config.vaultDomain | quote }},
      "enclaveType":"WalletDBEnclave",
      "sw": false,
      "pwa": false
    }

  # https://github.com/PharmaLedger-IMI/epi-workspace/blob/v1.3.0/trust-loader-config/dsu-explorer/loader/environment.js
  dsu-explorer-environment.js: |-
    export default {
      "appName": "DSU Explorer",
      "vault": "server",
      "agent": "browser",
      "system":   "any",
      "browser":  "any",
      "mode":  "dev-autologin",
      "vaultDomain":  {{ required "config.vaultDomain must be set" .Values.config.vaultDomain | quote}},
      "didDomain":  {{ required "config.vaultDomain must be set" .Values.config.vaultDomain | quote}},
      "enclaveType": "WalletDBEnclave",
      "sw": true,
      "pwa": false,
      "allowPinLogin": false
    }

  # https://github.com/PharmaLedger-IMI/epi-workspace/blob/v1.3.0/trust-loader-config/dsu-fabric-wallet/loader/environment.js
  dsu-fabric-environment.js: |-
    export default {
      "appName": "DSU_Fabric",
      "vault": "server",
      "agent": "browser",
      "system": "any",
      "browser": "any",
      "mode": {{ .Values.config.dsuFabricMode | quote }},
      "vaultDomain":  {{ required "config.vaultDomain must be set" .Values.config.vaultDomain | quote}},
      "didDomain":  {{ required "config.vaultDomain must be set" .Values.config.vaultDomain | quote}},
      "epiDomain":  {{ required "config.domain must be set" .Values.config.domain | quote}},
      "epiSubdomain":  {{ required "config.subDomain must be set" .Values.config.subDomain | quote}},
      "enclaveType": "WalletDBEnclave",
      "sw": false,
      "pwa": false,
      "allowPinLogin": false,
      "companyName": "Company Inc",
      "disabledFeatures": "",
      "lockFeatures": false,
      "epiProtocolVersion": 1
    }

  # https://github.com/PharmaLedger-IMI/epi-workspace/blob/v1.3.0/trust-loader-config/leaflet-wallet/loader/environment.js
  leaflet-environment.js: |-
    export default  {
      "appName": "eLeaflet",
      "vault": "server",
      "agent": "browser",
      "system":   "any",
      "browser":  "any",
      "mode":  "autologin",
      "vaultDomain":  {{ required "config.vaultDomain must be set" .Values.config.vaultDomain | quote}},
      "didDomain":  {{ required "config.vaultDomain must be set" .Values.config.vaultDomain | quote}},
      "enclaveType": "WalletDBEnclave",
      "sw": false,
      "pwa": false,
      "allowPinLogin": false,
      "lockFeatures": false,
      "disabledFeatures": "",
      "epiProtocolVersion": 1
    }

  # # 
  # # TODO: Remove with v1.3.1 - https://github.com/PharmaLedger-IMI/epi-workspace/tree/master/apihub-root/external-volume/wallets
  # #
  # leaflet-wallet_wallet-patch_environment.json: |-
  #   {
  #     "appName": "eLeaflet",
  #     "vault": "browser",
  #     "agent": "browser",
  #     "system":   "any",
  #     "browser":  "any",
  #     "stage":  "release",
  #     "legenda for properties": " vault:(server, browser) agent:(mobile,  browser)  system:(iOS, Android, any) browser:(Chrome, Firefox, any) stage:(development, release)"
  #   }

  # leaflet-wallet_wallet-patch_security.policies: |-
  #   {
  #     "cacheableFolders": ["/code"]
  #   }

  # demiurge-wallet_wallet-patch_messages_createEnclave.json: |-
  #   [
  #     {
  #       "messageType": "CreateEnclave",
  #       "enclaveName": "demiurgeSharedEnclave",
  #       "enclaveType": "WalletDBEnclave"
  #     },
  #     {
  #       "messageType": "CreateEnclave",
  #       "enclaveName": "epiEnclave",
  #       "enclaveType": "WalletDBEnclave"
  #     }
  #   ]

  # demiurge-wallet_wallet-patch_messages_createGroup.json: |-
  #   [
  #     {
  #       "messageType": "CreateGroup",
  #       "groupName": "ePI Administration Group"
  #     },
  #     {
  #       "messageType": "CreateGroup",
  #       "groupName": "ePI Write Group"
  #     }
  #   ]

{{- end }}
{{- end }}