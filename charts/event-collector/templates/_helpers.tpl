{{/*
Expand the name of the chart.
*/}}
{{- define "eventcollector.name" -}}
{{- $global := dict }}
{{- if .Values.global }}
{{- $global = index .Values.global "eventcollector" | default dict }}
{{- end }}
{{- $local := index .Values "eventcollector" | default dict }}
{{- $name := coalesce $global.nameOverride $local.nameOverride .Chart.Name }}
{{- $name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "eventcollector.fullname" -}}
{{- $global := dict }}
{{- if .Values.global }}
{{- $global = index .Values.global "eventcollector" | default dict }}
{{- end }}
{{- $local := index .Values "eventcollector" | default dict }}
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
{{- define "eventcollector.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "eventcollector.labels" -}}
{{- $global := dict }}
{{- if .Values.global }}
{{- $global = index .Values.global "eventcollector" | default dict }}
{{- end }}
{{- $local := index .Values "eventcollector" | default dict }}
helm.sh/chart: {{ include "eventcollector.chart" . }}
{{ include "eventcollector.selectorLabels" . }}
{{- $appVersion := coalesce $global.appVersion $local.appVersion .Chart.AppVersion }}
{{- if $appVersion }}
app.kubernetes.io/version: {{ $appVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "eventcollector.selectorLabels" -}}
app.kubernetes.io/name: {{ include "eventcollector.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "eventcollector.serviceAccountName" -}}
{{- $global := dict }}
{{- if .Values.global }}
{{- $global = index .Values.global "eventcollector" | default dict }}
{{- end }}
{{- $local := index .Values "eventcollector" | default dict }}
{{- $svcAcct := coalesce $global.serviceAccount $local.serviceAccount | default dict }}
{{- if $svcAcct }}
{{- if (default false $svcAcct.create) }}
{{- default (include "eventcollector.fullname" .) $svcAcct.name }}
{{- else }}
{{- default "default" $svcAcct.name }}
{{- end }}
{{- else }}
{{- "default" }}
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