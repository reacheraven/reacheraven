{{/*
Common helper templates for naming Reacheraven resources.
*/}}

{{- define "reacheraven.name" -}}
{{- if .Chart.Name -}}
{{- .Chart.Name | lower -}}
{{- else -}}
reacheraven
{{- end -}}
{{- end -}}

{{- define "reacheraven.fullname" -}}
{{- if .Release.Name -}}
{{- include "reacheraven.name" . | replace "_" "-" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
