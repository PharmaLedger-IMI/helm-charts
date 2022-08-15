{{- /*
Template for Configmap.

Arguments to be passed are 
- $ (index 0)
- . (index 1)
- suffix (index 2)
- dictionary (index 3) for annotations used for defining helm hooks.

See https://blog.flant.com/advanced-helm-templating/
*/}}
{{- define "backup-restore.configmap-server-config" -}}
{{- $ := index . 0 }}
{{- $suffix := index . 2 }}
{{- $annotations := index . 3 }}
  {{- with index . 1 }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "backup-restore.fullname" . }}-server-config{{ $suffix | default "" }}
  namespace: {{ template "backup-restore.namespace" . }}
  {{- with $annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  labels:
    {{- include "backup-restore.labels" . | nindent 4 }}
data:
  config.json: |-
{{- if .Values.config.serverConfigJson }}
{{ .Values.config.serverConfigJson | indent 4 }}
{{- else }}
    {
      "port": 3000,
      "s3BucketURI": "s3://pla-demo-backup/external-volume/",
      "pathToFolder":"/ePI-workspace/apihub-root/external-volume"
    }
{{- end }}

{{- end }}
{{- end }}