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
  namespace: {{ template "epi.namespace" . }}
  {{- with $annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  labels:
    {{- include "epi.labels" . | nindent 4 }}
data:
  # https://github.com/PharmaLedger-IMI/epi-workspace/blob/v1.3.0/trust-loader-config/demiurge-wallet/loader/environment.js
  demiurge-environment.js: |-
{{- if .Values.config.overrides.demiurgeEnvironmentJs }}
{{ .Values.config.overrides.demiurgeEnvironmentJs | indent 4 }}
{{- else }}
    export default {
      "appName": "Demiurge",
      "vault": "server",
      "agent": "browser",
      "system":   "any",
      "browser":  "any",
      "mode": "sso-direct",
      "vaultDomain":  {{ required "config.vaultDomain must be set" .Values.config.vaultDomain | quote }},
      "didDomain":  {{ required "config.vaultDomain must be set" .Values.config.vaultDomain | quote }},
      "enclaveType":"WalletDBEnclave",
      "companyName": {{ required "config.companyName must be set" .Values.config.companyName | quote }},
      "sw": false,
      "pwa": false
    }
{{- end }}

  # https://github.com/PharmaLedger-IMI/epi-workspace/blob/v1.3.0/trust-loader-config/dsu-explorer/loader/environment.js
  dsu-explorer-environment.js: |-
{{- if .Values.config.overrides.dsuExplorerEnvironmentJs }}
{{ .Values.config.overrides.dsuExplorerEnvironmentJs | indent 4 }}
{{- else }}
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
{{- end }}

  # https://github.com/PharmaLedger-IMI/epi-workspace/blob/v1.3.0/trust-loader-config/dsu-fabric-wallet/loader/environment.js
  dsu-fabric-environment.js: |-
{{- if .Values.config.overrides.dsuFabricEnvironmentJs }}
{{ .Values.config.overrides.dsuFabricEnvironmentJs | indent 4 }}
{{- else }}
    export default {
      "appName": "DSU_Fabric",
      "vault": "server",
      "agent": "browser",
      "system": "any",
      "browser": "any",
      "mode": "sso-direct",
      "vaultDomain":  {{ required "config.vaultDomain must be set" .Values.config.vaultDomain | quote}},
      "didDomain":  {{ required "config.vaultDomain must be set" .Values.config.vaultDomain | quote}},
      "epiDomain":  {{ required "config.domain must be set" .Values.config.domain | quote}},
      "epiSubdomain":  {{ required "config.subDomain must be set" .Values.config.subDomain | quote}},
      "enclaveType": "WalletDBEnclave",
      "sw": false,
      "pwa": false,
      "allowPinLogin": false,
      "companyName": {{ required "config.companyName must be set" .Values.config.companyName | quote }},
      "disabledFeatures": "02, 04, 05, 06, 07, 08, 09",
      "lockFeatures": true,
      "epiProtocolVersion": 1,
      "appBuildVersion": {{ required "config.epiVersion must be set" .Values.config.epiVersion | quote}}
    }
{{- end }}

  # https://github.com/PharmaLedger-IMI/epi-workspace/blob/v1.3.0/trust-loader-config/leaflet-wallet/loader/environment.js
  leaflet-environment.js: |-
{{- if .Values.config.overrides.leafletEnvironmentJs }}
{{ .Values.config.overrides.leafletEnvironmentJs | indent 4 }}
{{- else }}
    export default  {
      "appName": "eLeaflet",
      "vault": "server",
      "agent": "browser",
      "system":   "any",
      "browser":  "any",
      "mode":  "autologin",
      "vaultDomain":  {{ required "config.vaultDomain must be set" .Values.config.vaultDomain | quote}},
      "didDomain":  {{ required "config.vaultDomain must be set" .Values.config.vaultDomain | quote}},
      "epiDomain":  {{ required "config.domain must be set" .Values.config.domain | quote}},
      "enclaveType": "WalletDBEnclave",
      "sw": false,
      "pwa": false,
      "allowPinLogin": false,
      "lockFeatures": true,
      "disabledFeatures": "02, 04, 05, 06, 07, 08, 09",
      "easterEggEnabled": true,
      "epiProtocolVersion": 1,
      "appBuildVersion": {{ required "config.epiVersion must be set" .Values.config.epiVersion | quote}}
    }
{{- end }}

  lpwa-environment.js: |-
{{- if .Values.config.overrides.lpwaEnvironmentJs }}
{{ .Values.config.overrides.lpwaEnvironmentJs | indent 4 }}
{{- else }}
    export default {
      "epiDomain":  {{ required "config.domain must be set" .Values.config.domain | quote}},
      "epiProtocolVersion": 1,
      "appBuildVersion": {{ required "config.epiVersion must be set" .Values.config.epiVersion | quote}}
      "bdnsUrl": "https://raw.githubusercontent.com/PharmaLedger-IMI/mobile-bdns/master/bdns.json"
    }
{{- end }}

{{- end }}
{{- end }}