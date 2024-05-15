#!/bin/bash

VERSION=k8up-4.7.0
PWD=$(dirname "$0")

# see readme - https://github.com/k8up-io/k8up/tree/master/charts/k8up
mkdir -p ${PWD}/templates
curl -L https://github.com/k8up-io/k8up/releases/download/${VERSION}/k8up-crd.yaml > ${PWD}/templates/k8up-crd.yaml