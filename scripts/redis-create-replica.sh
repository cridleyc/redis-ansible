#!/bin/bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_env.sh"

if [[ $# -lt 5 ]]; then
  echo "*****************************************************************"
  echo "Usage: $0 <inventory_file> <replica_yaml> <src_db_name> <src_db_port> <replica_db_name> [replica_port] [ansible args]"
  echo "*****************************************************************"
  exit 1
fi

replica_port="${6:-12100}"
extra_arg_start=7

ansible-playbook -i "$(inventory_path "$1")" "$(playbook_path redis-create-replica.yaml)" \
  -e @"$2" \
  -e "src_db_name=$3 src_db_port=$4 rplc_db_name=$5 rplc_db_port=$replica_port" \
  "${@:extra_arg_start}"
