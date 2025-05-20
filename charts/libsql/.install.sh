#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

if [ "$(kubectl config current-context)" != "kind-kind" ]; then
  echo "kube context is an unexpected value"
  exit 1
fi

helm upgrade --install libsql .

