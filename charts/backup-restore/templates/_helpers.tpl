{{/*
Expand the name of the chart.
*/}}
{{- define "backup-restore.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "backup-restore.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "backup-restore.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Allow the release namespace to be overridden for multi-namespace deployments in combined charts
*/}}
{{- define "backup-restore.namespace" -}}
  {{- if .Values.namespaceOverride -}}
    {{- .Values.namespaceOverride -}}
  {{- else -}}
    {{- .Release.Namespace -}}
  {{- end -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "backup-restore.labels" -}}
helm.sh/chart: {{ include "backup-restore.chart" . }}
{{ include "backup-restore.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "backup-restore.selectorLabels" -}}
app.kubernetes.io/name: {{ include "backup-restore.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "backup-restore.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "backup-restore.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "epi.pvc" -}}
{{- if .Values.config.epiReleaseName }}
{{- .Values.config.epiReleaseName }}
{{- else }}
   "epi"
{{- end }}
{{- end }}

{{- define "backup-restore.awsAccessKeyId" -}}
{{- if .Values.secrets.awsAccessKeyId }}
{{- .Values.secrets.awsAccessKeyId }}
{{- else }}
{{- required "secrets.awsAccessKeyId must be set" "" }}
{{- end -}}
{{- end -}}

{{- define "backup-restore.awsSecretKey" -}}
{{- if .Values.secrets.awsSecretKey }}
{{- .Values.secrets.awsSecretKey }}
{{- else }}
{{- required "secrets.awsSecretKey must be set" "" }}
{{- end -}}
{{- end -}}

{{- define "backup-restore.awsDefaultRegion" -}}
{{- if .Values.secrets.awsDefaultRegion }}
{{- .Values.secrets.awsDefaultRegion }}
{{- else }}
{{- required "secrets.awsDefaultRegion must be set" "" }}
{{- end -}}
{{- end -}}