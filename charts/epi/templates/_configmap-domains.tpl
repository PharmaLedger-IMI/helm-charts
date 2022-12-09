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
  namespace: {{ template "epi.namespace" . }}
  {{- with $annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  labels:
    {{- include "epi.labels" . | nindent 4 }}
data:
  # Mapped to https://github.com/PharmaLedger-IMI/epi-workspace/tree/v1.3.0/apihub-root/external-volume/config/domains
  # e.g. 'epipoc.json'
  {{ required "config.domain must be set" .Values.config.domain }}.json: |-
{{- if .Values.config.overrides.domainConfigJson }}
{{ .Values.config.overrides.domainConfigJson | indent 4 }}
{{- else }}
    {
      "anchoring": {
        "type": "ETH",
        "option": {
          "endpoint": {{ required "config.ethadapterUrl must be set" .Values.config.ethadapterUrl | quote }}
        }
      },
      "skipOAuth": [
          "/bricking/{{ required "config.domain must be set" .Values.config.domain }}/get-brick",
          "/gtinOwner/{{ required "config.domain must be set" .Values.config.domain }}",
          "/leaflets/{{ required "config.domain must be set" .Values.config.domain }}",
          "/anchor/{{ required "config.domain must be set" .Values.config.domain }}/get-last-version"
      ],
{{- /*
     "messagesEndpoint": "http://localhost:8080/mappingEngine/{{ required "config.domain must be set" .Values.config.domain }}/{{ required "config.subDomain must be set" .Values.config.subDomain }}/saveResult",
*/}}
      "mappingEnginResultURLs": [{
        "endPointId": "{{ required "config.domain must be set" .Values.config.domain }}_{{ required "config.subDomain must be set" .Values.config.subDomain }}",
        "endPointURL": "http://localhost:8080/mappingEngine/{{ required "config.domain must be set" .Values.config.domain }}/{{ required "config.subDomain must be set" .Values.config.subDomain }}/saveResult"
      }],
      "mappingEnginResultURL": "http://localhost:8080/mappingEngine/{{ required "config.domain must be set" .Values.config.domain }}/{{ required "config.subDomain must be set" .Values.config.subDomain }}/saveResult",
      "enable": ["mq", "enclave"]
    }
{{- end }}

  # Mapped to https://github.com/PharmaLedger-IMI/epi-workspace/tree/v1.3.0/apihub-root/external-volume/config/domains
  # e.g. 'companyname.json'
  {{ required "config.subDomain must be set" .Values.config.subDomain }}.json: |-
{{- if .Values.config.overrides.subDomainConfigJson }}
{{ .Values.config.overrides.subDomainConfigJson | indent 4 }}
{{- else }}
    {
      "anchoring": {
        "type": "ETH",
        "option": {
          "endpoint": {{ required "config.ethadapterUrl must be set" .Values.config.ethadapterUrl | quote }}
        }
      },
      "skipOAuth": [
        "/bricking/{{ required "config.domain must be set" .Values.config.subDomain }}/get-brick",
        "/gtinOwner/{{ required "config.domain must be set" .Values.config.subDomain }}",
        "/leaflets/{{ required "config.domain must be set" .Values.config.subDomain }}",
        "/anchor/{{ required "config.domain must be set" .Values.config.subDomain }}/get-last-version"
      ],
      "enable": ["mq", "enclave"]
    }
{{- end }}

  # Mapped to https://github.com/PharmaLedger-IMI/epi-workspace/tree/v1.3.0/apihub-root/external-volume/config/domains
  # e.g. 'vault.companyname.json'
  {{ required "config.vaultDomain must be set" .Values.config.vaultDomain }}.json: |-
{{- if .Values.config.overrides.vaultDomainConfigJson }}
{{ .Values.config.overrides.vaultDomainConfigJson | indent 4 }}
{{- else }}
    {
      "anchoring": {
        "type": "FS",
         "option": {
           "enableBricksLedger": false
         }
      },
      "skipOAuth": [
        "/bricking/{{ required "config.vaultDomain must be set" .Values.config.vaultDomain }}/get-brick"
      ],
      "enable": ["mq", "enclave"]
    }
{{- end }}

{{- end }}
{{- end }}