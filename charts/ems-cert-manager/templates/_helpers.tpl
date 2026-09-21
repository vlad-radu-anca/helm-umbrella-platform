{{/*
Expand the name of the chart.
*/}}
{{- define "emscertmanager.name" -}}
{{- $global := dict }}
{{- if .Values.global }}
{{- $global = index .Values.global "emscertmanager" | default dict }}
{{- end }}
{{- $local := index .Values "emscertmanager" | default dict }}
{{- $name := coalesce $global.nameOverride $local.nameOverride .Chart.Name }}
{{- $name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "emscertmanager.fullname" -}}
{{- $global := dict }}
{{- if .Values.global }}
{{- $global = index .Values.global "emscertmanager" | default dict }}
{{- end }}
{{- $local := index .Values "emscertmanager" | default dict }}
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
{{- define "emscertmanager.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "emscertmanager.labels" -}}
{{- $global := dict }}
{{- if .Values.global }}
{{- $global = index .Values.global "emscertmanager" | default dict }}
{{- end }}
{{- $local := index .Values "emscertmanager" | default dict }}
helm.sh/chart: {{ include "emscertmanager.chart" . }}
{{ include "emscertmanager.selectorLabels" . }}
{{- $appVersion := coalesce $global.appVersion $local.appVersion .Chart.AppVersion }}
{{- if $appVersion }}
app.kubernetes.io/version: {{ $appVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "emscertmanager.selectorLabels" -}}
app.kubernetes.io/name: {{ include "emscertmanager.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "emscertmanager.serviceAccountName" -}}
{{- $global := dict }}
{{- if .Values.global }}
{{- $global = index .Values.global "emscertmanager" | default dict }}
{{- end }}
{{- $local := index .Values "emscertmanager" | default dict }}
{{- $svcAcct := coalesce $global.serviceAccount $local.serviceAccount | default dict }}
{{- if (default false $svcAcct.create) }}
{{- default (include "emscertmanager.fullname" .) $svcAcct.name }}
{{- else }}
{{- default "default" $svcAcct.name }}
{{- end }}
{{- end }}

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