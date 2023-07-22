{{- define "common.restic.backup" }}
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: restic-backup
spec:
  successfulJobsHistoryLimit: 1
  failedJobsHistoryLimit: 1
  concurrencyPolicy: Forbid
  schedule: {{ .cron.schedule | quote }}
  jobTemplate:
    spec:
      template:
        spec:
          {{- with .affinity }}
          affinity: {{ toYaml . | nindent 12 }}
          {{- end }}
          {{- with .tolerations }}
          tolerations: {{ toYaml . | nindent 12 }}
          {{- end }}
          initContainers:
          - name: restic-init
            image: {{ .image }}
            imagePullPolicy: Always
            command:
              - sh
              - -c
              - |
                restic init || echo "skipped"
            env: {{ toYaml .env | nindent 14 }}
          containers:
          - name: restic-backup
            image: {{ .image }}
            workingDir: /data
            args:
              - backup
              - --host
              - kubernetes
              - .
            env: {{ toYaml .env | nindent 14 }}
            volumeMounts:
              - name: backupdata
                mountPath: /data
                readOnly: true
          volumes:
            - name: backupdata
              persistentVolumeClaim:
                claimName: {{ .pvcName }}
          restartPolicy: OnFailure
{{- end }}