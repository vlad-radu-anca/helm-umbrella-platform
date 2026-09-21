{{/*
Expand the name of the chart.
*/}}
{{- define "coreApi.name" -}}
{{- $global := dict }}
{{- if .Values.global }}
{{- $global = index .Values.global "coreApi" | default dict }}
{{- end }}
{{- $local := index .Values "coreApi" | default dict }}
{{- $name := coalesce $global.nameOverride $local.nameOverride .Chart.Name }}
{{- $name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "coreApi.fullname" -}}
{{- $global := dict }}
{{- if .Values.global }}
{{- $global = index .Values.global "coreApi" | default dict }}
{{- end }}
{{- $local := index .Values "coreApi" | default dict }}
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
{{- define "coreApi.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "coreApi.labels" -}}
{{- $global := dict }}
{{- if .Values.global }}
{{- $global = index .Values.global "coreApi" | default dict }}
{{- end }}
{{- $local := index .Values "coreApi" | default dict }}
helm.sh/chart: {{ include "coreApi.chart" . }}
{{ include "coreApi.selectorLabels" . }}
{{- $appVersion := coalesce $global.appVersion $local.appVersion .Chart.AppVersion }}
{{- if $appVersion }}
app.kubernetes.io/version: {{ $appVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "coreApi.selectorLabels" -}}
app.kubernetes.io/name: {{ include "coreApi.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "coreApi.serviceAccountName" -}}
{{- $global := dict }}
{{- if .Values.global }}
{{- $global = index .Values.global "coreApi" | default dict }}
{{- end }}
{{- $local := index .Values "coreApi" | default dict }}
{{- $rbac := coalesce $global.rbac $local.rbac .Values.rbac | default dict }}
{{- $svcAcct := coalesce $global.serviceAccount $local.serviceAccount .Values.serviceAccount | default dict }}
{{- $serviceAccountName := coalesce $global.serviceAccountName $local.serviceAccountName $rbac.serviceAccountName }}
{{- if $serviceAccountName }}
{{- $serviceAccountName }}
{{- else if (default false $svcAcct.create) }}
{{- default (include "coreApi.fullname" .) $svcAcct.name }}
{{- else }}
{{- default "default" $svcAcct.name }}
{{- end }}
{{- end }}

{{- define "coreApi.Namespace" -}}
{{ .Release.Namespace }}
{{- end -}}

{{- define "coreApi.roleName" -}}
{{- $global := dict }}
{{- if .Values.global }}
{{- $global = index .Values.global "coreApi" | default dict }}
{{- end }}
{{- $local := index .Values "coreApi" | default dict }}
{{- $rbac := coalesce $global.rbac $local.rbac .Values.rbac | default dict }}
{{- $rbac.roleName | default "core-api-role" }}
{{- end }}

{{- define "coreApi.roleBindingName" -}}
{{- $global := dict }}
{{- if .Values.global }}
{{- $global = index .Values.global "coreApi" | default dict }}
{{- end }}
{{- $local := index .Values "coreApi" | default dict }}
{{- $rbac := coalesce $global.rbac $local.rbac .Values.rbac | default dict }}
{{- $rbac.roleBindingName | default "core-api-rolebinding" }}
{{- end }}

{{- define "coreApi.namespace" -}}
{{- $global := dict }}
{{- if .Values.global }}
{{- $global = index .Values.global "coreApi" | default dict }}
{{- end }}
{{- $local := index .Values "coreApi" | default dict }}
{{- $rbac := coalesce $global.rbac $local.rbac .Values.rbac | default dict }}
{{- $rbac.namespace | default .Release.Namespace }}
{{- end }}

{{/*
Check if RBAC is enabled
*/}}
{{- define "coreApi.rbacEnabled" -}}
{{- $global := dict }}
{{- if .Values.global }}
{{- $global = index .Values.global "coreApi" | default dict }}
{{- end }}
{{- $local := index .Values "coreApi" | default dict }}
{{- $rbac := coalesce $global.rbac $local.rbac .Values.rbac | default dict }}
{{- $rbac.enabled | default false }}
{{- end }}

{{/*
Get platform value
*/}}
{{- define "coreApi.platform" -}}
{{- $global := dict }}
{{- if .Values.global }}
{{- $global = index .Values.global "coreApi" | default dict }}
{{- end }}
{{- $local := index .Values "coreApi" | default dict }}
{{- $platform := coalesce $global.platform $local.platform .Values.platform }}
{{- $platform }}
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