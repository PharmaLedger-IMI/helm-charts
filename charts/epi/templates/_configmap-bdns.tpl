{{- /*
Template for Configmap.

Arguments to be passed are 
- $ (index 0)
- . (index 1)
- suffix (index 2)
- dictionary (index 3) for annotations used for defining helm hooks.

See https://blog.flant.com/advanced-helm-templating/
*/}}
{{- define "epi.configmap-bdns" -}}
{{- $ := index . 0 }}
{{- $suffix := index . 2 }}
{{- $annotations := index . 3 }}
  {{- with index . 1 }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "epi.fullname" . }}-bdns{{ $suffix | default "" }}
  namespace: {{ template "epi.namespace" . }}
  {{- with $annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  labels:
    {{- include "epi.labels" . | nindent 4 }}
data:
  # See https://github.com/PharmaLedger-IMI/epi-workspace/blob/v1.3.0/apihub-root/external-volume/config/bdns.hosts
  bdns.hosts: |-
{{- if .Values.config.overrides.bdnsHosts }}
{{ .Values.config.overrides.bdnsHosts | indent 4 }}
{{- else }}
    {
      "epipoc": {
          "anchoringServices": [
              "$ORIGIN"
          ],
          "notifications": [
              "$ORIGIN"
          ]
      },
      "epipoc.my-company": {
          "brickStorages": [
              "$ORIGIN"
          ],
          "anchoringServices": [
              "$ORIGIN"
          ],
          "notifications": [
              "$ORIGIN"
          ]
      },
      "epipoc.other": {
          "brickStorages": [
              "https://epipoc.other-company.com"
          ],
          "anchoringServices": [
              "https://epipoc.other-company.com"
          ],
          "notifications": [
              "https://epipoc.other-company.com"
          ]
      },
      "vault.my-company": {
          "replicas": [],
          "brickStorages": [
              "$ORIGIN"
          ],
          "anchoringServices": [
              "$ORIGIN"
          ],
          "notifications": [
              "$ORIGIN"
          ]
      }
    }
{{- end }}

{{- end }}
{{- end }}