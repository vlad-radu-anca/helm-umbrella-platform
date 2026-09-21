{{/*
Expand the name of the chart.
*/}}
{{- define "swagger.name" -}}
{{- $global := dict }}
{{- if .Values.global }}
{{- $global = index .Values.global "swagger" | default dict }}
{{- end }}
{{- $local := index .Values "swagger" | default dict }}
{{- $name := coalesce $global.nameOverride $local.nameOverride .Chart.Name }}
{{- $name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "swagger.fullname" -}}
{{- $global := dict }}
{{- if .Values.global }}
{{- $global = index .Values.global "swagger" | default dict }}
{{- end }}
{{- $local := index .Values "swagger" | default dict }}
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
{{- define "swagger.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "swagger.labels" -}}
{{- $global := dict }}
{{- if .Values.global }}
{{- $global = index .Values.global "swagger" | default dict }}
{{- end }}
{{- $local := index .Values "swagger" | default dict }}
helm.sh/chart: {{ include "swagger.chart" . }}
{{ include "swagger.selectorLabels" . }}
{{- $appVersion := coalesce $global.appVersion $local.appVersion .Chart.AppVersion }}
{{- if $appVersion }}
app.kubernetes.io/version: {{ $appVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "swagger.selectorLabels" -}}
app.kubernetes.io/name: {{ include "swagger.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "swagger.serviceAccountName" -}}
{{- $global := dict }}
{{- if .Values.global }}
{{- $global = index .Values.global "swagger" | default dict }}
{{- end }}
{{- $local := index .Values "swagger" | default dict }}
{{- $svcAcct := coalesce $global.serviceAccount $local.serviceAccount | default dict }}
{{- if (default false $svcAcct.create) }}
{{- default (include "swagger.fullname" .) $svcAcct.name }}
{{- else }}
{{- default "default" $svcAcct.name }}
{{- end }}
{{- end }}

{{/*
populate swagger host
*/}}
{{- define "swagger.host" -}}
{{- $global := dict }}
{{- if .Values.global }}
{{- $global = index .Values.global "swagger" | default dict }}
{{- end }}
{{- $local := index .Values "swagger" | default dict }}
{{- $globalNgf := default dict $global.ngf }}
{{- $localNgf := default dict $local.ngf }}
{{- $hostname := coalesce $globalNgf.hostname $localNgf.hostname }}
{{- tpl $hostname . -}}
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