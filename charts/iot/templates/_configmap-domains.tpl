{{- /*
Template for Configmap. Arguments to be passed are $ . suffix and an dictionary for annotations used for defining helm hooks.
See https://blog.flant.com/advanced-helm-templating/
*/}}
{{- define "iot.configmap-domains" -}}
{{- $ := index . 0 }}
{{- $suffix := index . 2 }}
{{- $annotations := index . 3 }}
{{- with index . 1 }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "iot.fullname" . }}-domains{{ $suffix | default "" }}
  {{- with $annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  labels:
    {{- include "iot.labels" . | nindent 4 }}
data:
  {{ required "config.domain must be set" .Values.config.domain }}.json: |-
    {
      "anchoring": {
        "type": "FS",
        "option": {
          "enableBricksLedger": false
        },
        "commands": {
          "addAnchor": "anchor"
        }
      },
      "skipOAuth": [
        "/bricking/{{ required "config.domain must be set" .Values.config.domain }}/get-brick"
      ],
      "enable": ["mq", "enclave"],
      "mq_fsQueueLength": 20000
    }

  {{ required "config.subDomain must be set" .Values.config.subDomain }}.json: |-
    {
      "anchoring": {
        "type": "FS",
        "option": {
          "enableBricksLedger": false
        },
        "commands": {
          "addAnchor": "anchor"
        }
      },
      "skipOAuth": [
        "/bricking/{{ required "config.subDomain must be set" .Values.config.subDomain }}/get-brick"
      ],
      "enable": ["mq", "enclave"],
      "mq_fsQueueLength": 20000
    }

  {{ required "config.vaultDomain must be set" .Values.config.vaultDomain }}.json: |-
    {
      "anchoring": {
        "type": "FS",
         "option": {
           "enableBricksLedger": false
         }
      },
      "skipOAuth": [
        "/bricking/{{ required "config.vaultDomain must be set" .Values.config.vaultDomain }}",
        "/anchor/{{ required "config.vaultDomain must be set" .Values.config.vaultDomain }}"
      ],
      "enable": ["mq", "enclave"],
      "mq_fsQueueLength": 20000
    }

  default.json: |-
    {
      "anchoring": {
        "type": "FS",
        "option": {
         "enableBricksLedger": false
        },
        "commands": {
          "addAnchor": "anchor"
        }
      },
      "skipOAuth": [
        "/bricking/{{ required "config.vaultDomain must be set" .Values.config.vaultDomain }}",
        "/anchor/{{ required "config.vaultDomain must be set" .Values.config.vaultDomain }}"
      ],
      "enable": ["mq", "enclave"],
      "mq_fsQueueLength": 20000
    }

{{- end }}
{{- end }}
