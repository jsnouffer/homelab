{{- define "common.restic.credentials" }}
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
        key: BACKBLAZE_MASTER_KEY_ID
    - secretKey: applicationKey
      remoteRef:
        key: BACKBLAZE_MASTER_APPLICATION_KEY
    - secretKey: resticKey
      remoteRef:
        key: RESTIC_ENCRYPTION_KEY
{{- end }}