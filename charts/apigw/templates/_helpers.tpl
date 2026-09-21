{{/*
Expand the name of the chart.
*/}}
{{- define "apigw.name" -}}
{{- $global := dict }}
{{- if .Values.global }}
{{- $global = index .Values.global "apigw" | default dict }}
{{- end }}
{{- $local := index .Values "apigw" | default dict }}
{{- $name := coalesce $global.nameOverride $local.nameOverride .Chart.Name }}
{{- $name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
Truncate at 63 chars because of DNS name limits.
*/}}
{{- define "apigw.fullname" -}}
{{- $global := dict }}
{{- if .Values.global }}
{{- $global = index .Values.global "apigw" | default dict }}
{{- end }}
{{- $local := index .Values "apigw" | default dict }}
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
{{- define "apigw.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "apigw.labels" -}}
{{- $global := dict }}
{{- if .Values.global }}
{{- $global = index .Values.global "apigw" | default dict }}
{{- end }}
{{- $local := index .Values "apigw" | default dict }}
helm.sh/chart: {{ include "apigw.chart" . }}
{{ include "apigw.selectorLabels" . }}
{{- $appVersion := coalesce $global.appVersion $local.appVersion .Chart.AppVersion }}
{{- if $appVersion }}
app.kubernetes.io/version: {{ $appVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "apigw.selectorLabels" -}}
app.kubernetes.io/name: {{ include "apigw.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "apigw.serviceAccountName" -}}
{{- $global := dict }}
{{- if .Values.global }}
{{- $global = index .Values.global "apigw" | default dict }}
{{- end }}
{{- $local := index .Values "apigw" | default dict }}
{{- $svcAcct := coalesce $global.serviceAccount $local.serviceAccount | default dict }}
{{- if (default false $svcAcct.create) }}
  {{- default (include "apigw.fullname" .) $svcAcct.name }}
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