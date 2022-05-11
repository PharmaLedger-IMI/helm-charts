{{/*
Expand the name of the chart.
*/}}
{{- define "epi.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "epi.fullname" -}}
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
{{- define "epi.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "epi.labels" -}}
helm.sh/chart: {{ include "epi.chart" . }}
{{ include "epi.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels for runner
*/}}
{{- define "epi.selectorLabels" -}}
app.kubernetes.io/name: {{ include "epi.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Selector labels for runner used by kubectl --selector=key1=value1,key2=value2
*/}}
{{- define "epi.selectorLabelsKubectl" -}}
app.kubernetes.io/name={{ include "epi.name" . }},app.kubernetes.io/instance={{ .Release.Name }}
{{- end }}

{{/*
Selector labels for builder
*/}}
{{- define "epi.builderSelectorLabels" -}}
app.kubernetes.io/name: {{ include "epi.name" . }}-builder
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Selector labels for builder used by kubectl --selector=key1=value1,key2=value2
*/}}
{{- define "epi.builderSelectorLabelsKubectl" -}}
app.kubernetes.io/name={{ include "epi.name" . }}-builder,app.kubernetes.io/instance={{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "epi.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "epi.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
    The full image repository:tag[@sha256:sha] for the runner
*/}}
{{- define "epi.runner.image" -}}
{{- if .Values.runner.image.sha -}}
{{ .Values.runner.image.repository }}:{{ .Values.runner.image.tag | default .Chart.AppVersion }}@sha256:{{ .Values.runner.image.sha }}
{{- else -}}
{{ .Values.runner.image.repository }}:{{ .Values.runner.image.tag | default .Chart.AppVersion }}
{{- end -}}
{{- end -}}

{{/*
    The full image repository:tag[@sha256:sha] for the builder
*/}}
{{- define "epi.builder.image" -}}
{{- if .Values.builder.image.sha -}}
{{ .Values.builder.image.repository }}:{{ .Values.builder.image.tag }}@sha256:{{ .Values.builder.image.sha }}
{{- else -}}
{{ .Values.builder.image.repository }}:{{ .Values.builder.image.tag }}
{{- end -}}
{{- end -}}

{{/*
    The full image repository:tag[@sha256:sha] for kubectl
*/}}
{{- define "epi.kubectl.image" -}}
{{- if .Values.kubectl.image.sha -}}
{{ .Values.kubectl.image.repository }}:{{ .Values.kubectl.image.tag }}@sha256:{{ .Values.kubectl.image.sha }}
{{- else -}}
{{ .Values.kubectl.image.repository }}:{{ .Values.kubectl.image.tag }}
{{- end -}}
{{- end -}}

{{/*
The Name of the ConfigMap for the Build Info Data
*/}}
{{- define "epi.configMapBuildInfoName" -}}
{{- printf "%s-%s" (include "epi.fullname" .) "build-info" }}
{{- end }}

{{/*
The builder image that was built at last. Return an empty string if not yet exists.
*/}}
{{- define "epi.lastBuilderImage" -}}
{{- $configMap := lookup "v1" "ConfigMap" .Release.Namespace (include "epi.configMapBuildInfoName" .) -}}
{{- if $configMap -}}
{{ $configMap.data.lastBuilderImage | default "" }}
{{- end -}}
{{- end -}}

