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

{{/*
Convert a map of environment variables to Kubernetes env list format
Usage: {{ include "linea.env" .Values.component.env }}
*/}}
{{- define "linea.env" -}}
{{- if and . (kindIs "map" .) (ne (len .) 0) }}
{{- range $key, $value := . }}
- name: {{ $key }}
  value: {{ $value | quote }}
{{- end }}
{{- end }}
{{- end -}}
