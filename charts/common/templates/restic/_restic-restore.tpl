{{- define "common.restic.restore" }}
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: restic-restore
spec:
  successfulJobsHistoryLimit: 1
  failedJobsHistoryLimit: 1
  concurrencyPolicy: Forbid
  schedule: "* * 31 2 *" # never runs
  suspend: true
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
          containers:
          - image: {{ .image }}
            imagePullPolicy: IfNotPresent
            name: restic
            args:
            - restore
            - {{ default "latest" .restore.version }}
            - --target
            - /data
            env: {{ toYaml .env | nindent 14 }}
            volumeMounts:
            - mountPath: /data
              name: backupdata
          restartPolicy: OnFailure
          volumes:
          - name: backupdata
            persistentVolumeClaim:
              claimName: {{ .pvcName }}
{{- end }}