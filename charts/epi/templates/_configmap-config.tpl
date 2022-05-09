{{- /*
Template for Configmap.

Arguments to be passed are 
- $ (index 0)
- . (index 1)
- suffix (index 2)
- dictionary (index 3) for annotations used for defining helm hooks.

See https://blog.flant.com/advanced-helm-templating/
*/}}
{{- define "epi.configmap-config" -}}
{{- $ := index . 0 }}
{{- $suffix := index . 2 }}
{{- $annotations := index . 3 }}
{{- with index . 1 }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "epi.fullname" . }}-config{{ $suffix | default "" }}
  {{- with $annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  labels:
    {{- include "epi.labels" . | nindent 4 }}
data:
  # See https://github.com/PharmaLedger-IMI/epi-workspace/blob/v1.3.0/env.json
  env.json: |
    {
      "PSK_TMP_WORKING_DIR": "tmp",
      "PSK_CONFIG_LOCATION": "../apihub-root/external-volume/config",
      "DEV": false,
      "VAULT_DOMAIN": {{ required "config.vaultDomain must be set" .Values.config.vaultDomain | quote}},
      "BUILD_SECRET_KEY": "nosecretfordevelopers"
    }

  # https://github.com/PharmaLedger-IMI/epi-workspace/blob/v1.3.0/apihub-root/external-volume/config/apihub.json
  apihub.json: |-
{{ required "config.apihub must be set" .Values.config.apihub | indent 4 }}

{{- end }}
{{- end }}