{{/*
Main entrypoint for the common library chart. It will render all underlying templates based on the provided values.
*/}}
{{- define "common.all" -}}
  {{- if .Values.common.resticBackups.enabled }}
  {{- include "common.restic.all" $ }}
  {{- end }}
{{- end -}}