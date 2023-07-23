{{- define "common.restic.backup" }}
{{- $ctx := $.Values.common.resticBackups }}
{{- range $name, $value := $ctx.targets }}
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: restic-backup-{{ $name }}
spec:
  successfulJobsHistoryLimit: 1
  failedJobsHistoryLimit: 1
  concurrencyPolicy: Forbid
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
            env: {{ toYaml $ctx.env | nindent 14 }}
              - name: RESTIC_REPOSITORY
                value: {{ $value.bucket | quote }}
          containers:
          - name: restic-backup
            image: {{ $ctx.image }}
            workingDir: /data
            args:
              - backup
              - --host
              - kubernetes
              - .
            env: {{ toYaml $ctx.env | nindent 14 }}
              - name: RESTIC_REPOSITORY
                value: {{ $value.bucket | quote }}
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