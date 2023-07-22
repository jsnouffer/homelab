{{- define "common.restic.all" }}
{{- with .Values.common.resticBackups }}
{{- include "common.restic.credentials" . }}
{{- if ( .prune | default dict).enabled }}
{{- include "common.restic.prune" . }}
{{- include "common.restic.rbac" $ }}
{{- end }}
{{- if ( .cron | default dict).enabled }}
{{- include "common.restic.backup" . }}
{{- end }}
{{- if ( .restore | default dict).enabled }}
{{- include "common.restic.restore" . }}
{{- end }}
{{- end }}
{{- end }}