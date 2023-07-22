{{- define "common.restic.prune" }}
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: restic-prune
spec:
  successfulJobsHistoryLimit: 1
  failedJobsHistoryLimit: 1
  concurrencyPolicy: Forbid
  schedule: {{ .prune.schedule | quote }}
  jobTemplate:
    spec:
      template:
        spec:
          serviceAccountName: restic-backups
          initContainers:
            - name: prune-backups
              image: {{ .image }}
              command:
                - sh
                - -c
                - |
                  restic forget \
                    --keep-daily={{ .prune.keepDaily }} \
                    --keep-weekly={{ .prune.keepWeekly }} \
                    --keep-monthly={{ .prune.keepMonthly }} \
                    --prune
                  restic snapshots --json > /snapshots/snapshots.json
              env: {{ toYaml .env | nindent 16 }}
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
                  kubectl create configmap restic-backups-snapshots --from-file=/tmp/snapshots.json --dry-run=client -o yaml | kubectl apply -f -
              volumeMounts:
                - name: snapshots
                  mountPath: /snapshots
          volumes:
            - name: snapshots
              emptyDir: {}
          restartPolicy: OnFailure
{{- end }}