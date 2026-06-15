#!/bin/bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_env.sh"

# update existing ldap mapping for map_uid pointed to by arg 2 - 
# using json pointed to by script command line arg 3
# map_uid can be found using "redis-list-ldap-mapping.sh"
#
if [[ $# -lt 3 ]]; then
  echo "*****************************************************************"
  echo "Usage: $0 <inventory_file> <mapping uid> <input json file>"
  echo "note: the env var 're_inv' should be set to point to the subdir"
  echo "      containing <inventory_file>"
  echo "*****************************************************************"
  exit 1
fi
#
ansible-playbook -i "$(inventory_path "$1")" \
  "$(playbook_path redis-updt-ldap-mapping.yaml)" \
  -e "map_uid=$2" -e @"$3"
