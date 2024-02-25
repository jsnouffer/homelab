{{- define "common.restic.backup" }}
{{- $ctx := $.Values.common.resticBackups }}
{{- range $name, $value := $ctx.targets }}
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: restic-backup-{{ $name }}
  labels:
    restic-backup: {{ $name }}
spec:
  successfulJobsHistoryLimit: 0
  failedJobsHistoryLimit: 1
  concurrencyPolicy: Forbid
  timeZone: America/New_York
  schedule: {{ $ctx.cron.schedule | quote }}
  jobTemplate:
    spec:
      template:
        spec:
          {{- with $value.affinity }}
          affinity: {{ toYaml . | nindent 12 }}
          {{- end }}
          {{- with $value.tolerations }}
          tolerations: {{ toYaml . | nindent 12 }}
          {{- end }}
          initContainers:
          - name: restic-init
            image: {{ $ctx.image }}
            imagePullPolicy: Always
            command:
              - sh
              - -c
              - |
                restic init || echo "skipped"
            {{- if hasPrefix "b2" $value.bucket }}
            env: {{ toYaml $ctx.env.b2 | nindent 14 }}
              - name: RESTIC_REPOSITORY
                value: {{ $value.bucket | quote }}
            {{- else }}
            env: {{ toYaml $ctx.env.s3 | nindent 14 }}
              - name: RESTIC_REPOSITORY
                value: {{ printf "%s/%s" $ctx.minioUrl $value.bucket | quote }}
            {{- end }}
          containers:
          - name: restic-backup
            image: {{ $ctx.image }}
            workingDir: /data
            args:
              - backup
              - --host
              - kubernetes
              {{- range $value.tags }}
              - --tag
              - {{ tpl . $ }}
              {{- end }}
              - .
            {{- if hasPrefix "b2" $value.bucket }}
            env: {{ toYaml $ctx.env.b2 | nindent 14 }}
              - name: RESTIC_REPOSITORY
                value: {{ $value.bucket | quote }}
            {{- else }}
            env: {{ toYaml $ctx.env.s3 | nindent 14 }}
              - name: RESTIC_REPOSITORY
                value: {{ printf "%s/%s" $ctx.minioUrl $value.bucket | quote }}
            {{- end }}
            volumeMounts:
              - name: backupdata
                mountPath: /data
                readOnly: true
          volumes:
            - name: backupdata
              persistentVolumeClaim:
                claimName: {{ $value.pvcName }}
          restartPolicy: OnFailure
{{- end }}
{{- end }}