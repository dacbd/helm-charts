{{/*
Expand the name of the chart.
*/}}
{{- define "libsql.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "libsql.fullname" -}}
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
{{- define "libsql.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "libsql.labels" -}}
helm.sh/chart: {{ include "libsql.chart" . }}
{{ include "libsql.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "libsql.selectorLabels" -}}
app.kubernetes.io/name: {{ include "libsql.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "libsql.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "libsql.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "libsql.envName" -}}
{{- printf "%s-%s" (include "libsql.fullname" .) "env" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "libsql.secretName" -}}
{{- if ne .Values.sqld.secretName "" }}
{{- printf "%s" .Values.sqld.secretName -}}
{{- else }}
{{- printf "%s-%s" (include "libsql.fullname" .) "credentials" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
