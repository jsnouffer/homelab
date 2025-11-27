{{- define "common.restic.credentials" }}
---
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: restic-backup-credentials
spec:
  secretStoreRef:
    kind: ClusterSecretStore
    name: infisical-secret-store
  target:
    deletionPolicy: Delete
  data:
    - secretKey: b2KeyID
      remoteRef:
        key: /restic/backblaze
        property: keyId
    - secretKey: b2ApplicationKey
      remoteRef:
        key: /restic/backblaze
        property: applicationKey
    - secretKey: b2-s3-access-key-id
      remoteRef:
        key: /restic/backblaze
        property: s3-access-key-id
    - secretKey: b2-s3-secret-access-key
      remoteRef:
        key: /restic/backblaze
        property: s3-secret-access-key
    - secretKey: s3AccessKey
      remoteRef:
        key: /restic/minio
        property: accessKey
    - secretKey: s3SecretKey
      remoteRef:
        key: /restic/minio
        property: secretKey
    - secretKey: resticKey
      remoteRef:
        key: /restic
        property: encryptionKey
{{- end }}