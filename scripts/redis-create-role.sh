#!/bin/bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_env.sh"

if [[ $# -lt 2 ]]; then
  echo "*****************************************************************"
  echo "Usage: $0 <inventory_file> <role_yaml> [ansible args]"
  echo "Example: $0 single_nodes.yml roles/custom-roles.yaml"
  echo "*****************************************************************"
  exit 1
fi

ansible-playbook -i "$(inventory_path "$1")" "$(playbook_path redis-create-role.yaml)" \
  -e @"$2" "${@:3}"
