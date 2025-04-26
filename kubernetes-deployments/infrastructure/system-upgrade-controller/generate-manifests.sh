#!/usr/bin/env bash

CHART_NAME=system-upgrade-controller

rm -f Chart.lock
rm -rf charts/${CHART_NAME}
mkdir -p charts/${CHART_NAME}/crds
mkdir -p charts/${CHART_NAME}/templates
cd charts/${CHART_NAME}

cat > Chart.yaml << EOF
apiVersion: v2
name: ${CHART_NAME}
version: 1.0.0
EOF

curl -sL https://github.com/rancher/system-upgrade-controller/releases/latest/download/crd.yaml | kubectl-slice -o crds
curl -sL https://github.com/rancher/system-upgrade-controller/releases/latest/download/system-upgrade-controller.yaml | kubectl-slice -o templates

sed -i 's/namespace:.*/namespace: {{ .Release.Namespace }}/g' templates/*.yaml
sed -i 's/name:.*/name: {{ .Release.Namespace }}/g' templates/namespace*.yaml