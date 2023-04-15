{{- define "common.restic.backups" -}}
{{- with .Values.common.resticBackups }}
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: backblaze-credentials
spec:
  secretStoreRef:
    kind: ClusterSecretStore
    name: doppler-secret-store
  target:
    name: backblaze-credentials
    deletionPolicy: Delete
  data:
    - secretKey: keyID
      remoteRef:
        key: BACKBLAZE_RADARR_KEY_ID
    - secretKey: applicationKey
      remoteRef:
        key: BACKBLAZE_RADARR_APPLICATION_KEY
    - secretKey: resticKey
      remoteRef:
        key: RESTIC_ENCRYPTION_KEY
{{- if ( .prune | default dict).enabled }}
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: restic-prune
spec:
  concurrencyPolicy: Forbid
  schedule: {{ .prune.schedule | quote }}
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: restic
            image: {{ .image }}
            args:
              - forget
              - --keep-last={{ .prune.keepLast }}
              - --keep-weekly={{ .prune.keepWeekly }}
              - --keep-monthly={{ .prune.keepMonthly }}
              - --prune
            env: {{ toYaml .env | nindent 14 }}
          restartPolicy: OnFailure
{{- end }}
{{- if ( .cron | default dict).enabled }}
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: restic-backup
spec:
  concurrencyPolicy: Forbid
  schedule: {{ .cron.schedule | quote }}
  jobTemplate:
    spec:
      template:
        spec:
          affinity: {{ toYaml .affinity | nindent 12 }}
          containers:
          - name: restic
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
{{- if ( .init | default dict).enabled }}
---
apiVersion: batch/v1
kind: Job
metadata:
  name: restic-init
  annotations:
    argocd.argoproj.io/hook: PostSync
    argocd.argoproj.io/hook-delete-policy: BeforeHookCreation
spec:
  backoffLimit: 1
  selector:
    matchLabels:
      job-name: restic-init
  suspend: false
  template:
    metadata:
      labels:
        job-name: restic-init
    spec:
      restartPolicy: Never
      containers:
      - name: restic
        image: {{ .image }}
        imagePullPolicy: Always
        command:
          - sh
          - -c
          - |
            restic init || echo "skipped"
        env: {{ toYaml .env | nindent 10 }}
{{- end }}
{{- if ( .restore | default dict).enabled }}
---
apiVersion: batch/v1
kind: Job
metadata:
  name: restic-restore
spec:
  template:
    spec:
      affinity: {{ toYaml .affinity | nindent 12 }}
      containers:
      - image: {{ .image }}
        imagePullPolicy: IfNotPresent
        name: restic
        args:
        - restore
        - latest
        - --target
        - /data
        env: {{ toYaml .env | nindent 10 }}
        volumeMounts:
        - mountPath: /data
          name: backupdata
      restartPolicy: OnFailure
      volumes:
      - name: backupdata
        persistentVolumeClaim:
          claimName: {{ .pvcName }}
{{- end }}
{{- end }}
{{- end -}}