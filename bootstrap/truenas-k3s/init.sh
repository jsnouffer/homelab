#!/usr/bin/env bash

sftp admin@barenas.jsnouff.net <<< 'put ./config /tmp/jailmaker-k3s-config'
ssh admin@barenas.jsnouff.net "sudo /mnt/plex/jailmaker/jlmkr.py create --start --config /tmp/jailmaker-k3s-config k3s"

#setup kubeconfig
mkdir -p ~/.kube
ssh -o StrictHostKeyChecking=no cloud-user@dalek-jast.jsnouff.net "sudo cat /etc/rancher/k3s/k3s.yaml" > /tmp/k3s-kubeconfig
sed -i 's/127.0.0.1/dalek-jast.jsnouff.net/g' /tmp/k3s-kubeconfig
sed -i 's/default/lorien/g' /tmp/k3s-kubeconfig
cp ~/.kube/config /tmp/kubeconfig
KUBECONFIG=/tmp/k3s-kubeconfig:/tmp/kubeconfig kubectl config view --flatten > ~/.kube/config

kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: argocd
  namespace: kube-system
---
apiVersion: v1
kind: Secret
metadata:
  name: argocd-token
  namespace: kube-system
  annotations:
    kubernetes.io/service-account.name: argocd
type: kubernetes.io/service-account-token
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: argocd
rules:
- apiGroups:
  - '*'
  resources:
  - '*'
  verbs:
  - '*'
- nonResourceURLs:
  - '*'
  verbs:
  - '*'
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: argocd
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: argocd
subjects:
- kind: ServiceAccount
  name: argocd
  namespace: kube-system
EOF

export CA_DATA=$(kubectl get secrets -n kube-system argocd-token -o jsonpath='{.data.ca\.crt}')
export SA_TOKEN=$(kubectl get secrets -n kube-system argocd-token -o jsonpath='{.data.token}' | base64 -d)
echo $SA_TOKEN

kubectl config use-context skaro
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: cluster-k3s
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: cluster
type: Opaque
stringData:
  name: k3s
  server: https://dalek-jast.jsnouff.net:6443
  config: |
    {
      "bearerToken": "${SA_TOKEN}",
      "tlsClientConfig": {
        "insecure": false,
        "caData": "${CA_DATA}"
      }
    }
EOF

export INFISICAL_SECRET=$(kubectl get secrets -n external-secrets infisical-api-token -o json)
kubectl config use-context lorien
kubectl create ns external-secrets --dry-run=client -o yaml | kubectl apply -f -
echo $INFISICAL_SECRET | kubectl apply -f -