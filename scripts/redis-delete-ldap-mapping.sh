#!/bin/bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_env.sh"

# delete mapping of ldap group to redis role - requires the ID of the 
# mapping - IDs can be displayed by 'redis-list-ldap-mapping.sh'
if [[ $# -lt 2 ]]; then
  echo "*****************************************************************"
  echo "Usage: $0 <inventory_file> <ldap_mapping id>"
  echo "note: the env var 're_inv' should be set to point to the subdir"
  echo "      containing <inventory_file>"
  echo "*****************************************************************"
  exit 1
fi
ansible-playbook -i "$(inventory_path "$1")" \
  "$(playbook_path redis-delete-ldap-mapping.yaml)" \
  -e "map_uid=$2"
