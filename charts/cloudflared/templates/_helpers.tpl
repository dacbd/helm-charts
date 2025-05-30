{{/*
Kill completely invalid values.
*/}}
{{- if and (eq .Values.cloudflare.tunnelToken "") (eq .Values.cloudflare.tunnelName "") -}}
{{- fail "When tunnelToken is empty, tunnelName must be defined for a local tunnel configuration" -}}
{{- end -}}

{{/*
Expand the name of the chart.
*/}}
{{- define "cloudflared.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cloudflared.fullname" -}}
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
{{- define "cloudflared.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "cloudflared.labels" -}}
helm.sh/chart: {{ include "cloudflared.chart" . }}
{{ include "cloudflared.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "cloudflared.selectorLabels" -}}
app.kubernetes.io/name: {{ include "cloudflared.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "cloudflared.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "cloudflared.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "cloudflared.antiAffinity" -}}
podAntiAffinity:
  preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 10
      podAffinityTerm:
       topologyKey: kubernetes.io/hostname
       labelSelector:
         matchExpressions:
           {{- range $k, $v := include "cloudflared.selectorLabels" . | fromYaml }}
           - key: {{ $k }}
             operator: In
             values:
               - {{ $v }}
           {{- end }}
{{- end }}

{{- define "cloudflared.envName" -}}
{{- printf "%s-%s" (include "cloudflared.fullname" .) "env" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "cloudflared.args" -}}
- tunnel
{{- if eq .Values.cloudflare.tunnelToken "" }}
- --config
- /etc/cloudflared/config/config.yaml
{{- end }}
- run
{{- end -}}

{{- define "cloudflared.secretName" -}}
{{- if ne .Values.cloudflare.secretName "" }}
{{- printf "%s" .Values.cloudflare.secretName -}}
{{- else }}
{{- printf "%s-%s" (include "cloudflared.fullname" .) "credentials" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
