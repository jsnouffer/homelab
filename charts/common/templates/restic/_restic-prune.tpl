{{- define "common.restic.prune" }}
{{- $ctx := $.Values.common.resticBackups }}
{{- range $name, $value := $ctx.targets }}
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: restic-prune-{{ $name }}
  labels:
    restic-prune: {{ $name }}
spec:
  successfulJobsHistoryLimit: 0
  failedJobsHistoryLimit: 1
  concurrencyPolicy: Forbid
  timeZone: America/New_York
  schedule: {{ $ctx.prune.schedule | quote }}
  jobTemplate:
    spec:
      template:
        spec:
          serviceAccountName: restic-backups
          initContainers:
            - name: prune-backups
              image: {{ $ctx.image }}
              command:
                - sh
                - -c
                - |
                  restic forget \
                    --keep-daily={{ $ctx.prune.keepDaily }} \
                    --keep-weekly={{ $ctx.prune.keepWeekly }} \
                    --keep-monthly={{ $ctx.prune.keepMonthly }} \
                    --prune
                  restic snapshots --json > /snapshots/snapshots.json
              {{- $bucketName := "" }}
              {{- if hasPrefix "b2" $value.bucket }}
              env: {{ toYaml $ctx.env.b2 | nindent 16 }}
                {{- $bucketName = $value.bucket }}
                - name: RESTIC_REPOSITORY
                  value: {{ $value.bucket | quote }}
              {{- else }}
              env: {{ toYaml $ctx.env.s3 | nindent 16 }}
                {{- $bucketName = printf "%s/%s" $ctx.minioUrl $value.bucket }}
                - name: RESTIC_REPOSITORY
                  value: {{ printf "%s/%s" $ctx.minioUrl $value.bucket | quote }}
              {{- end }}
              volumeMounts:
                - name: snapshots
                  mountPath: /snapshots
          containers:
            - name: save-snapshot-history
              image: dtzar/helm-kubectl:latest
              imagePullPolicy: Always
              command:
                - /bin/bash
                - -c
                - |
                  cat /snapshots/snapshots.json | jq > /tmp/snapshots.json
                  kubectl create configmap restic-backups-snapshots-{{ $name }} --from-file=/tmp/snapshots.json --dry-run=client -o yaml | kubectl apply -f -
                  kubectl label --overwrite=true configmap restic-backups-snapshots-{{ $name }} \
                    restic.snapshots/name={{ $name }}
                  kubectl annotate --overwrite=true configmap restic-backups-snapshots-{{ $name }} \
                    restic.snapshots/bucket={{ $bucketName }} \
                    restic.snapshots/pvc={{ $value.pvcName }}
              volumeMounts:
                - name: snapshots
                  mountPath: /snapshots
          volumes:
            - name: snapshots
              emptyDir: {}
          restartPolicy: OnFailure
{{- end }}
{{- end }}