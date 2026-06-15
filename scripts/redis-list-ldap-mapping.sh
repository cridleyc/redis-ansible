#!/bin/bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_env.sh"

# This scripts will list both ldap mappings and roles for the cluster
# pointed to by the 'inventory_file'
if [[ $# -ne 1 ]]; then
  echo "*****************************************************************"
  echo "Usage: $0 <inventory_file> <ldap_mapping id>"
  echo "note: the env var 're_inv' should be set to point to the subdir"
  echo "      containing <inventory_file>"
  echo "*****************************************************************"
  exit 1
fi
ansible-playbook -i "$(inventory_path "$1")" "$(playbook_path redis-list-ldap-mapping.yaml)"
