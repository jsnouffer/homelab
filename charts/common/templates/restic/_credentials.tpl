{{- define "common.restic.credentials" }}
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: restic-backup-credentials
spec:
  secretStoreRef:
    kind: ClusterSecretStore
    name: doppler-secret-store
  target:
    name: restic-backup-credentials
    deletionPolicy: Delete
  data:
    - secretKey: b2KeyID
      remoteRef:
        key: BACKBLAZE_MASTER_KEY_ID
    - secretKey: b2ApplicationKey
      remoteRef:
        key: BACKBLAZE_MASTER_APPLICATION_KEY
    - secretKey: s3AccessKey
      remoteRef:
        key: MINIO_ACCESS_KEY
    - secretKey: s3SecretKey
      remoteRef:
        key: MINIO_SECRET_KEY
    - secretKey: resticKey
      remoteRef:
        key: RESTIC_ENCRYPTION_KEY
{{- end }}