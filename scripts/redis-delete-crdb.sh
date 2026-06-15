#!/bin/bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_env.sh"

if [[ $# -lt 1 ]]; then
  echo "*****************************************************************"
  echo "Usage: $0 <crdb_guid> [ansible args]"
  echo "Environment variables required: clusterAPI, clusterUser, clusterPass"
  echo "*****************************************************************"
  exit 1
fi

: "${clusterAPI:?Set clusterAPI before running this script}"
: "${clusterUser:?Set clusterUser before running this script}"
: "${clusterPass:?Set clusterPass before running this script}"

ansible-playbook "$(playbook_path redis-delete-crdb.yaml)" \
  -e "crdb_id=$1 clusterAPI=$clusterAPI clusterUser=$clusterUser clusterPass=$clusterPass" \
  "${@:2}"
