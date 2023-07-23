{{- define "common.restic.prune" }}
{{- $ctx := $.Values.common.resticBackups }}
{{- range $name, $value := $ctx.targets }}
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: restic-prune-{{ $name }}
spec:
  successfulJobsHistoryLimit: 1
  failedJobsHistoryLimit: 1
  concurrencyPolicy: Forbid
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
              env: {{ toYaml $ctx.env | nindent 16 }}
                - name: RESTIC_REPOSITORY
                  value: {{ $value.bucket | quote }}
              volumeMounts:
                - name: snapshots
                  mountPath: /snapshots
          containers:
            - name: save-snapshot-history
              image: bitnami/kubectl:latest
              imagePullPolicy: Always
              command:
                - /bin/bash
                - -c
                - |
                  cat /snapshots/snapshots.json | jq > /tmp/snapshots.json
                  kubectl create configmap restic-backups-snapshots-{{ $name }} --from-file=/tmp/snapshots.json --dry-run=client -o yaml | kubectl apply -f -
              volumeMounts:
                - name: snapshots
                  mountPath: /snapshots
          volumes:
            - name: snapshots
              emptyDir: {}
          restartPolicy: OnFailure
{{- end }}
{{- end }}