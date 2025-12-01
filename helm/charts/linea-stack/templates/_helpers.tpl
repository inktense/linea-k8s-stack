{{/*
Common helpers for naming and labels
*/}}
{{- define "linea.name" -}}
{{- default .Chart.Name .Values.nameOverride -}}
{{- end -}}

{{- define "linea.fullname" -}}
{{- printf "%s-%s" (include "linea.name" .) .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "linea.labels" -}}
app.kubernetes.io/name: {{ include "linea.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app.kubernetes.io/managed-by: Helm
{{- end -}}
