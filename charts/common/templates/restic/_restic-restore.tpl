{{- define "common.restic.restore" }}
{{- $ctx := $.Values.common.resticBackups }}
{{- range $name, $value := $ctx.targets }}
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: restic-restore-{{ $name }}
  labels:
    restic-restore: {{ $name }}
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
          {{- with $value.affinity }}
          affinity: {{ toYaml . | nindent 12 }}
          {{- end }}
          {{- with $value.tolerations }}
          tolerations: {{ toYaml . | nindent 12 }}
          {{- end }}
          containers:
          - image: {{ $ctx.image }}
            imagePullPolicy: IfNotPresent
            name: restic
            args:
            - restore
            - {{ default "latest" $value.restoreVersion }}
            - --target
            - /data
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
            - mountPath: /data
              name: backupdata
          restartPolicy: OnFailure
          volumes:
          - name: backupdata
            persistentVolumeClaim:
              claimName: {{ $value.pvcName }}
{{- end }}
{{- end }}