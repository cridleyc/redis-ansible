#!/bin/bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_env.sh"

if [[ $# -lt 1 ]]; then
  echo "*****************************************************************"
  echo "Usage: $0 <inventory_file> [ansible args]"
  echo "*****************************************************************"
  exit 1
fi

ansible-playbook -i "$(inventory_path "$1")" "$(playbook_path redis-update-cluster.yaml)" \
  "${@:2}"
