#!/bin/bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_env.sh"

# command line args:
# arg 1 is database name 
# app_name is used as db identifier in the acl project
if [[ $# -ne 2 ]]; then
  echo "*****************************************************************"
  echo "Usage: $0 <inventory_file> <db name>"
  echo "note: the env var 're_inv' should be set to point to the subdir"
  echo "      containing <inventory_file>"
  echo "      <db name> is CASE SENSITIVE - must match exactly"
  echo "*****************************************************************"
  exit 1
fi

ansible-playbook -i "$(inventory_path "$1")" "$(playbook_path redis-delete-db-name.yaml)" \
  -e "db_name=$2"
