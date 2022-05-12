{{- /*
Template for Secret.

Arguments to be passed are 
- $ (index 0)
- . (index 1)
- suffix (index 2)
- dictionary (index 3) for annotations used for defining helm hooks.

See https://blog.flant.com/advanced-helm-templating/
*/}}
{{- define "epi.secret" -}}
{{- $ := index . 0 }}
{{- $suffix := index . 2 }}
{{- $annotations := index . 3 }}
{{- with index . 1 }}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "epi.fullname" . }}{{ $suffix | default "" }}
  namespace: {{ template "epi.namespace" . }}
  {{- with $annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  labels:
    {{- include "epi.labels" . | nindent 4 }}
type: Opaque
data:
  # See https://github.com/PharmaLedger-IMI/epi-workspace/blob/v1.3.0/env.json
  env.json: |-
{{- if .Values.config.overrides.envJson }}
{{ .Values.config.overrides.envJson | b64enc | indent 4 }}
{{- else }}
{{ include "epi.envJson" . | b64enc | indent 4 }}
{{- end }}

  # https://github.com/PharmaLedger-IMI/epi-workspace/blob/v1.3.0/apihub-root/external-volume/config/apihub.json
  apihub.json: |-
{{- if .Values.config.overrides.apihubJson }}
{{ .Values.config.overrides.apihubJson | b64enc | indent 4 }}
{{- else }}
{{ include "epi.apihubJson" . | b64enc | indent 4 }}
{{- end }}

{{- end }}
{{- end }}