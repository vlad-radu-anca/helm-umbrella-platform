{{/*
Expand the name of the chart.
*/}}
{{- define "webui.name" -}}
{{- $global := dict }}
{{- if .Values.global }}
{{- $global = index .Values.global "webui" | default dict }}
{{- end }}
{{- $local := index .Values "webui" | default dict }}
{{- $name := coalesce $global.nameOverride $local.nameOverride .Chart.Name }}
{{- $name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "webui.fullname" -}}
{{- $global := dict }}
{{- if .Values.global }}
{{- $global = index .Values.global "webui" | default dict }}
{{- end }}
{{- $local := index .Values "webui" | default dict }}
{{- $fullnameOverride := coalesce $global.fullnameOverride $local.fullnameOverride }}
{{- if $fullnameOverride }}
{{- $fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := coalesce $global.nameOverride $local.nameOverride .Chart.Name }}
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
{{- define "webui.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "webui.labels" -}}
{{- $global := dict }}
{{- if .Values.global }}
{{- $global = index .Values.global "webui" | default dict }}
{{- end }}
{{- $local := index .Values "webui" | default dict }}
helm.sh/chart: {{ include "webui.chart" . }}
{{ include "webui.selectorLabels" . }}
{{- $appVersion := coalesce $global.appVersion $local.appVersion .Chart.AppVersion }}
{{- if $appVersion }}
app.kubernetes.io/version: {{ $appVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "webui.selectorLabels" -}}
app.kubernetes.io/name: {{ include "webui.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "webui.serviceAccountName" -}}
{{- $global := dict }}
{{- if .Values.global }}
{{- $global = index .Values.global "webui" | default dict }}
{{- end }}
{{- $local := index .Values "webui" | default dict }}
{{- $svcAcct := coalesce $global.serviceAccount $local.serviceAccount | default dict }}
{{- if (default false $svcAcct.create) }}
{{- default (include "webui.fullname" .) $svcAcct.name }}
{{- else }}
{{- default "default" $svcAcct.name }}
{{- end }}
{{- end }}

{{- define "webui.Namespace" -}}
{{ .Release.Namespace }}
{{- end -}}

{{/*
Get platform value with global precedence - works in umbrella chart context
*/}}
{{- define "platform" -}}
{{- if .Values.global -}}
{{- .Values.global.platform | default "onprem" -}}
{{- else if .Values.platform -}}
{{- .Values.platform -}}
{{- else -}}
onprem
{{- end -}}
{{- end }}