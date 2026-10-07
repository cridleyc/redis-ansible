#!/bin/bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_env.sh"

# Set quorum node. If node id is omitted, the playbook discovers the first node
# with total RAM below quorum_node_memory_threshold_gb.
# 
# arg 1 - inventory file - found in subdir indicated by $re_inv
# arg 2 - optional quorum node id - node ids can be listed with "rladmin status"
#
if [[ $# -lt 1 ]]; then
  echo "*****************************************************************"
  echo "Usage: $0 <inventory_file> [quorum node id] [ansible args]"
  echo "note: the env var 're_inv' should be set to point to the subdir"
  echo "      containing <inventory_file>"
  echo "example auto: $0 single_nodes.yml"
  echo "example explicit: $0 single_nodes.yml 3"
  echo "*****************************************************************"
  exit 1
fi

inventory_file="$1"
shift

quorum_args=()
if [[ $# -gt 0 && "$1" =~ ^[0-9]+$ ]]; then
  quorum_args=(-e "quorum_node=$1")
  shift
fi

ansible-playbook -i "$(inventory_path "$inventory_file")" "$(playbook_path redis-set-quorum-node.yaml)" \
  "${quorum_args[@]}" "$@"
