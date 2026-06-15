#!/bin/bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_env.sh"

# Update current ldap configuration - server uri,login, dn, etc
#
if [[ $# -lt 2 ]]; then
  echo "*****************************************************************"
  echo "Usage: $0 <inventory_file> <ldap json file>"
  echo "note: the env var 're_inv' should be set to point to the subdir"
  echo "      containing <inventory_file>"
  echo "      <ldap json file> - absolute or relative path to json file"
  echo "*****************************************************************"
  exit 1
fi
#
ansible-playbook -i "$(inventory_path "$1")" "$(playbook_path redis-ldap-update.yaml)" -e @"$2"
