#!/bin/bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_env.sh"

# Set quorum node using node id - must be done before provisioning databases
# 
# arg 1 - inventory file - found in subdir indicated by $re_inv
# arg 2 - quorum node id - node ids can be listed with "rladmin status"
#
if [[ $# -lt 2 ]]; then
  echo "*****************************************************************"
  echo "Usage: $0 <inventory_file> <quorum node id>"
  echo "note: the env var 're_inv' should be set to point to the subdir"
  echo "      containing <inventory_file>"
  echo "*****************************************************************"
  exit 1
fi
ansible-playbook -i "$(inventory_path "$1")" "$(playbook_path redis-set-quorum-node.yaml)" \
  -e "quorum_node=$2"
