{{- /*
Template for Configmap. Arguments to be passed are $ . suffix and an dictionary for annotations used for defining helm hooks.
See https://blog.flant.com/advanced-helm-templating/
*/}}
{{- define "iot-adapter.configmap-config" -}}
{{- $ := index . 0 }}
{{- $suffix := index . 2 }}
{{- $annotations := index . 3 }}
{{- with index . 1 }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "iot-adapter.fullname" . }}-config{{ $suffix | default "" }}
  {{- with $annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  labels:
    {{- include "iot-adapter.labels" . | nindent 4 }}
data:
  env.json: |-
    {
      "BDNS_ROOT_HOSTS": "http://eco-iot:80",
      "PSK_TMP_WORKING_DIR": "tmp",
      "PSK_CONFIG_LOCATION": "../apihub-root/external-volume/config",
      "DEV": false,
      "DID_DOMAIN": {{ required "config.domain must be set" .Values.config.domain | quote}},
      "VAULT_DOMAIN": {{ required "config.vaultDomain must be set" .Values.config.vaultDomain | quote}},
      "BUILD_SECRET_KEY": {{ required "config.iotAdapter.BUILD_SECRET_KEY must be set" .Values.config.iotAdapter.BUILD_SECRET_KEY | quote}},
      "IOT_ADAPTOR_DID": {{ required "config.iotAdapter.IOT_ADAPTOR_DID must be set" .Values.config.iotAdapter.IOT_ADAPTOR_DID | quote}},
      "IOT_ADAPTOR_PORT": {{ required "config.iotAdapter.IOT_ADAPTOR_PORT must be set" .Values.config.iotAdapter.IOT_ADAPTOR_PORT | quote}},
      "FITBIT_UPDATE_INTERVAL": {{ required "config.iotAdapter.FITBIT_UPDATE_INTERVAL must be set" .Values.config.iotAdapter.FITBIT_UPDATE_INTERVAL | quote}}
      "STORAGE_API_BASE_URL": {{ required "config.iotAdapter.STORAGE_API_BASE_URL must be set" .Values.config.iotAdapter.STORAGE_API_BASE_URL | quote}},
      "STORAGE_API_APP_ID": {{ required "config.iotAdapter.STORAGE_API_APP_ID must be set" .Values.config.iotAdapter.STORAGE_API_APP_ID | quote}},
      "STORAGE_API_REST_API_KEY": {{ required "config.iotAdapter.STORAGE_API_REST_API_KEY must be set" .Values.config.iotAdapter.STORAGE_API_REST_API_KEY | quote}}
    }
  credentials-service.json: |-
{{ required "config.credentialsService must be set" .Values.config.credentialsService | indent 4 }}

  apihub.json: |-
{{ required "config.apihub must be set" .Values.config.apihub | indent 4 }}

{{- end }}
{{- end }}
