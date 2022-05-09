{{- /*
Template for Configmap.

Arguments to be passed are 
- $ (index 0)
- . (index 1)
- suffix (index 2)
- dictionary (index 3) for annotations used for defining helm hooks.

See https://blog.flant.com/advanced-helm-templating/
*/}}
{{- define "epi.configmap-domains" -}}
{{- $ := index . 0 }}
{{- $suffix := index . 2 }}
{{- $annotations := index . 3 }}
{{- with index . 1 }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "epi.fullname" . }}-domains{{ $suffix | default "" }}
  {{- with $annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  labels:
    {{- include "epi.labels" . | nindent 4 }}
data:
  # Mapped to https://github.com/PharmaLedger-IMI/epi-workspace/tree/v1.3.0/apihub-root/external-volume/config/domains
  {{ required "config.domain must be set" .Values.config.domain }}.json: |-
    {
      "anchoring": {
        "type": "ETH",
        "option": {
          "endpoint": {{ required "config.ethadapterUrl must be set" .Values.config.ethadapterUrl | quote }}
        }
      },
      "messagesEndpoint": "http://localhost:8080/mappingEngine/{{ required "config.domain must be set" .Values.config.domain }}/{{ required "config.subDomain must be set" .Values.config.subDomain }}/saveResult",
      "enable": ["mq", "enclave"]
    }

  # Mapped to https://github.com/PharmaLedger-IMI/epi-workspace/tree/v1.3.0/apihub-root/external-volume/config/domains
  {{ required "config.subDomain must be set" .Values.config.subDomain }}.json: |-
    {
      "anchoring": {
        "type": "ETH",
        "option": {
          "endpoint": {{ required "config.ethadapterUrl must be set" .Values.config.ethadapterUrl | quote }}
        }
      },
      "enable": ["mq", "enclave"]
    }

  # Mapped to https://github.com/PharmaLedger-IMI/epi-workspace/tree/v1.3.0/apihub-root/external-volume/config/domains
  {{ required "config.vaultDomain must be set" .Values.config.vaultDomain }}.json: |-
    {
      "anchoring": {
        "type": "FS",
         "option": {
           "enableBricksLedger": false
         }
      },
      "enable": ["mq", "enclave"]
    }

{{- end }}
{{- end }}