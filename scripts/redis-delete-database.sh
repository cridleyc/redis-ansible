#!/bin/bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_env.sh"

if [[ $# -lt 2 ]]; then
  echo "*****************************************************************"
  echo "Usage: $0 <inventory_file> <bdb_uid> [ansible args]"
  echo "*****************************************************************"
  exit 1
fi

ansible-playbook -i "$(inventory_path "$1")" "$(playbook_path redis-delete-database.yaml)" \
  -e "bdb_id=$2" "${@:3}"
