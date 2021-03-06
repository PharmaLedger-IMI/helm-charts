{{/*
Expand the name of the chart.
*/}}
{{- define "csc.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "csc.fullname" -}}
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
{{- define "csc.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "csc.labels" -}}
helm.sh/chart: {{ include "csc.chart" . }}
{{ include "csc.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "csc.selectorLabels" -}}
app.kubernetes.io/name: {{ include "csc.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "csc.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "csc.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
The Name of the ConfigMap for the Seeds Data
*/}}
{{- define "csc.configMapSeedsBackupName" -}}
{{- printf "%s-%s" (include "csc.fullname" .) "seedsbackup" }}
{{- end }}

{{/*
Lookup potentially existing seedsBackup data
*/}}
{{- define "csc.seedsBackupData" -}}
{{- $configMap := lookup "v1" "ConfigMap" .Release.Namespace (include "csc.configMapSeedsBackupName" .) -}}
{{- if $configMap -}}
{{/*
    Reusing existing data
*/}}
seedsBackup: {{ $configMap.data.seedsBackup | default "" | quote }}
{{- else -}}
{{/*
    Use new data
*/}}
seedsBackup: ""
{{- end -}}
{{- end -}}

{{/*
    The full image repository:tag[@sha256:sha]
*/}}
{{- define "csc.image" -}}
{{- if .Values.image.sha -}}
{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}@sha256:{{ .Values.image.sha }}
{{- else -}}
{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}
{{- end -}}
{{- end -}}


{{/*
    The full image of kubectl repository:tag[@sha256:sha]
*/}}
{{- define "csc.kubectlImage" -}}
{{- if .Values.kubectl.image.sha -}}
{{ .Values.kubectl.image.repository }}:{{ .Values.kubectl.image.tag }}@sha256:{{ .Values.kubectl.image.sha }}
{{- else -}}
{{ .Values.kubectl.image.repository }}:{{ .Values.kubectl.image.tag }}
{{- end -}}
{{- end -}}

{{/*
The Name of the ConfigMap for the Build Info Data
*/}}
{{- define "csc.configMapBuildInfoName" -}}
{{- printf "%s-%s" (include "csc.fullname" .) "build-info" }}
{{- end }}

{{/*
The image that was built at last. Return an empty string if not yet exists.
*/}}
{{- define "csc.lastBuiltImage" -}}
{{- $configMap := lookup "v1" "ConfigMap" .Release.Namespace (include "csc.configMapBuildInfoName" .) -}}
{{- if $configMap -}}
{{ $configMap.data.lastBuiltImage | default "" }}
{{- end -}}
{{- end -}}

