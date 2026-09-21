{{/*
populate ngf hostname
*/}}
{{- define "ngf.hostname" -}}
{{- $global := dict }}
{{- if .Values.global }}
{{- $global = index .Values.global "ngf" | default dict }}
{{- end }}
{{- $local := index .Values "ngf" | default dict }}
{{- $hostname := coalesce $global.hostname $local.hostname }}
{{- tpl $hostname . -}}
{{- end }}

{{/*
populate ngf allowOrigin
*/}}
{{- define "ngf.allowOrigin" -}}
{{- $global := dict }}
{{- if .Values.global }}
{{- $global = index .Values.global "ngf" | default dict }}
{{- end }}
{{- $local := index .Values "ngf" | default dict }}
{{- $allowOrigin := coalesce $global.allowOrigin $local.allowOrigin }}
{{- tpl $allowOrigin . -}}
{{- end }}

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