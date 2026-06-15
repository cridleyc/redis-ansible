#!/bin/bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_env.sh"

if [[ $# -lt 1 ]]; then
  echo "*****************************************************************"
  echo "Usage: $0 <crdb_json> [dbname] [ansible args]"
  echo "Environment variables required: clusterAPI, clusterUser, clusterPass"
  echo "Optional placeholder variables: user1, password1, user2, password2"
  echo "*****************************************************************"
  exit 1
fi

: "${clusterAPI:?Set clusterAPI before running this script}"
: "${clusterUser:?Set clusterUser before running this script}"
: "${clusterPass:?Set clusterPass before running this script}"

re_json="$1"
re_dbname="${2:-$(basename "${re_json%.*}")}"

ansible-playbook "$(playbook_path redis-create-crdb.yaml)" \
  -e "re_json=$re_json" \
  -e "dbname=$re_dbname" \
  -e "clusterAPI=$clusterAPI clusterUser=$clusterUser clusterPass=$clusterPass" \
  -e "user1=${user1:-} password1=${password1:-} user2=${user2:-} password2=${password2:-}" \
  "${@:3}"
