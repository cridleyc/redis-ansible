#!/bin/bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_env.sh"

# Update Redis Enterprise using inventory file.
# By default the release applied will be 're_url' defined in the group_vars
# for the selected inventory. Additional ansible args can be appended,
# for example: -e re_url=<download link>
if [[ $# -lt 1 ]]; then
  echo "*****************************************************************"
  echo "Usage: $0 <inventory_file> [ansible args]"
  echo "Example: $0 rocky8_clstr.yml -e re_url=https://..."
  echo "*****************************************************************"
  exit 1
fi

ansible-playbook -i "$(inventory_path "$1")" "$(playbook_path redis-upgrade.yaml)" \
  "${@:2}"
