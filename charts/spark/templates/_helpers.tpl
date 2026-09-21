{{/*
Expand the name of the chart.
*/}}
{{- define "spark.name" -}}
{{- $global := dict }}
{{- if .Values.global }}
{{- $global = index .Values.global "spark" | default dict }}
{{- end }}
{{- $local := index .Values "spark" | default dict }}
{{- $name := coalesce $global.nameOverride $local.nameOverride .Chart.Name }}
{{- $name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "spark.fullname" -}}
{{- $global := dict }}
{{- if .Values.global }}
{{- $global = index .Values.global "spark" | default dict }}
{{- end }}
{{- $local := index .Values "spark" | default dict }}
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
{{- define "spark.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "spark.labels" -}}
{{- $global := dict }}
{{- if .Values.global }}
{{- $global = index .Values.global "spark" | default dict }}
{{- end }}
{{- $local := index .Values "spark" | default dict }}
helm.sh/chart: {{ include "spark.chart" . }}
{{ include "spark.selectorLabels" . }}
{{- $appVersion := coalesce $global.appVersion $local.appVersion .Chart.AppVersion }}
{{- if $appVersion }}
app.kubernetes.io/version: {{ $appVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "spark.selectorLabels" -}}
app.kubernetes.io/name: {{ include "spark.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "spark.serviceAccountName" -}}
{{- $global := dict }}
{{- if .Values.global }}
{{- $global = index .Values.global "spark" | default dict }}
{{- end }}
{{- $local := index .Values "spark" | default dict }}
{{- $svcAcct := coalesce $global.serviceAccount $local.serviceAccount | default dict }}
{{- if (default false $svcAcct.create) }}
{{- default (include "spark.fullname" .) $svcAcct.name }}
{{- else }}
{{- default "default" $svcAcct.name }}
{{- end }}
{{- end }}

{{/*
Expand the name of the chart.
*/}}
{{- define "snmpproxy.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "snmpproxy.fullname" -}}
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
{{- define "snmpproxy.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "snmpproxy.labels" -}}
helm.sh/chart: {{ include "snmpproxy.chart" . }}
{{ include "snmpproxy.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "snmpproxy.selectorLabels" -}}
app.kubernetes.io/name: {{ include "snmpproxy.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "snmpproxy.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "snmpproxy.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "snmpproxy.Namespace" -}}
{{ .Release.Namespace }}
{{- end -}}

{{/*
Get platform value with global precedence - works in umbrella chart context
*/}}
{{- define "platform" -}}
{{- if .Values.global -}}
{{- .Values.platform | default "onprem" -}}
{{- else if .Values.platform -}}
{{- .Values.platform -}}
{{- else -}}
onprem
{{- end -}}
{{- end }}

{{- define "spark.loadBalancerIP" -}}
{{- if and (kindIs "map" .Values.global) (hasKey .Values.global "loadBalancerIP") -}}
{{ get .Values.global "loadBalancerIP" }}
{{- else -}}
{{ .Values.loadBalancerIP | default "0.0.0.0" }}
{{- end -}}
{{- end }}