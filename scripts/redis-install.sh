#!/bin/bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_env.sh"

# install Redis Enterprise using inventory file 
# install bundle pointed to by re_url var in the corresponding group_var file
# 
#
# arg 1 - selects the inventory file in ./inventory
#
if [[ $# -lt 1 ]]; then
  echo "*****************************************************************"
  echo "Usage: $0 <inventory_file>"
  echo "note: the env var 're_inv' should be set to point to the subdir"
  echo "      containing <inventory_file>"
  echo "*****************************************************************"
  exit 1
fi
ansible-playbook -i "$(inventory_path "$1")" "$(playbook_path redis-install.yaml)" "${@:2}"
