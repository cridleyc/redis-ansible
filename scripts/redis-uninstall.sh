#!/bin/bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_env.sh"

# uninstall Redis Enterprise completely from all nodes in inventory_file
# arg 1 selects the inventory file 
# note: the scripts 'setbase.sh' can be used to set the environment 
if [[ $# -ne 1 ]]; then
  echo "*****************************************************************"
  echo "Usage: $0 <inventory_file>"
  echo "note: the env var 're_inv' should be set to point to the subdir"
  echo "      containing <inventory_file>"
  echo "*****************************************************************"
  exit 1
fi
ansible-playbook -i "$(inventory_path "$1")" "$(playbook_path redis-uninstall.yaml)"
