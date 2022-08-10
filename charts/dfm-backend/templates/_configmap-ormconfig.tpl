{{- /*
Template for Configmap.

Arguments to be passed are 
- $ (index 0)
- . (index 1)
- suffix (index 2)
- dictionary (index 3) for annotations used for defining helm hooks.

See https://blog.flant.com/advanced-helm-templating/
*/}}
{{- define "dfm-backend.configmap-ormconfig" -}}
{{- $ := index . 0 }}
{{- $suffix := index . 2 }}
{{- $annotations := index . 3 }}
  {{- with index . 1 }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "dfm-backend.fullname" . }}-ormconfig{{ $suffix | default "" }}
  namespace: {{ template "dfm-backend.namespace" . }}
  {{- with $annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  labels:
    {{- include "dfm-backend.labels" . | nindent 4 }}
data:
  ormconfig.json: |-
{{- if .Values.config.ormconfigJson }}
{{ .Values.config.ormconfigJson | indent 4 }}
{{- else }}
        [{
          "name": "default",
          "type": "postgres",
          "host": "postgresql.default.svc.cluster.local",
          "port": 5432,
          "username": "acdc",
          {{- /*
            # pragma: allowlist nextline secret
        */}}"password": "acdc",
          "database": "acdc",
          "entities": [
              "dist/acdc/*.entity.js"
          ],
          "synchronize" : false
        }]

{{- end }}

{{- end }}
{{- end }}