{{- /*
Template for Configmap. Arguments to be passed are $ . suffix and an dictionary for annotations used for defining helm hooks.
See https://blog.flant.com/advanced-helm-templating/
*/}}
{{- define "csc.configmap-config" -}}
{{- $ := index . 0 }}
{{- $suffix := index . 2 }}
{{- $annotations := index . 3 }}
{{- with index . 1 }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "csc.fullname" . }}-config{{ $suffix | default "" }}
  {{- with $annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  labels:
    {{- include "csc.labels" . | nindent 4 }}
data:
  env.json: |
    {
      "PSK_TMP_WORKING_DIR": "tmp",
      "PSK_CONFIG_LOCATION": "../apihub-root/external-volume/config",
      "SSAPPS_FAVORITE_EDFS_ENDPOINT": "http://localhost:8080",
      "IS_PRODUCTION_BUILD": true,
      "VAULT_DOMAIN": {{ required "config.vaultDomain must be set" .Values.config.vaultDomain | quote}}
    }

  apihub.json: |-
{{ required "config.apihub must be set" .Values.config.apihub | indent 4 }}

{{- end }}
{{- end }}
