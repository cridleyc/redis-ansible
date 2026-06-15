#!/bin/bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_env.sh"

# this play is used to upgrade bdbs and crdbs following a cluster upgrade
# it will report errors for databases already on the latest version but will
# continue to process any remaining databases
# 
if [[ $# -lt 1 ]]; then
  echo "*****************************************************************"
  echo "Usage: $0 <inventory_file>"
  echo "note: the env var 're_inv' should be set to point to the subdir"
  echo "      containing <inventory_file>"
  echo "*****************************************************************"
  exit 1
fi
ansible-playbook -i "$(inventory_path "$1")" "$(playbook_path redis-upgrade-databases.yaml)"
