{{- /*
Template for Configmap. Arguments to be passed are $ . suffix and an dictionary for annotations used for defining helm hooks.
See https://blog.flant.com/advanced-helm-templating/
*/}}
{{- define "fgt.configmap-domains" -}}
{{- $ := index . 0 }}
{{- $suffix := index . 2 }}
{{- $annotations := index . 3 }}
{{- with index . 1 }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "fgt.fullname" . }}-domains{{ $suffix | default "" }}
  {{- with $annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  labels:
    {{- include "fgt.labels" . | nindent 4 }}
data:
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
      }
    }

  {{ required "config.domain must be set" .Values.config.domain }}.json: |-
{{- if .Values.config.ethadapterUrl }}
    {
      "anchoring": {
        "type": "ETH",
        "option": {
          "endpoint": {{ .Values.config.ethadapterUrl }}
        },
        "commands": {
          "addAnchor": "anchor"
        }
      },
      "enable": ["mq"],
      "skipOAuth": [
        "/bricking/traceability/get-brick"
      ]
    }
{{- else }}
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
      "enable": ["mq"],
      "skipOAuth": [
        "/bricking/traceability/get-brick"
      ]
    }
{{- end }}

  {{ required "config.subDomain must be set" .Values.config.subDomain }}.json: |-
{{- if .Values.config.ethadapterUrl }}
    {
      "anchoring": {
        "type": "ETH",
        "option": {
          "endpoint": {{ .Values.config.ethadapterUrl }}
        },
        "commands": {
          "addAnchor": "anchor"
        }
      },
      "enable": ["mq"],
      "skipOAuth": [
        "/bricking/traceability/get-brick"
      ]
    }
{{- else }}
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
      "enable": ["mq"],
      "skipOAuth": [
        "/bricking/traceability/get-brick"
      ]
    }
{{- end }}

  {{ required "config.vaultDomain must be set" .Values.config.vaultDomain }}.json: |-
    {
      "anchoring": {
        "type": "FS",
        "option": {}
      }
    }
  
  vault.json: |-
    {
      "anchoring": {
        "type": "FS",
        "option": {}
      }
    }
{{- end }}
{{- end }}