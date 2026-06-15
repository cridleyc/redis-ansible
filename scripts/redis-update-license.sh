#!/bin/bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_env.sh"

# update a cluster license 
# arg 1 - inventory file
# arg 2 - license file
#
if [[ $# -ne 2 ]]; then
  echo "*****************************************************************"
  echo "Usage: $0 <inventory_file> <license_file>"
  echo "note: the env var 're_inv' should be set to point to the subdir"
  echo "      containing <inventory_file>"
  echo "      <license_file> - absolute or relative path to license"
  echo "*****************************************************************"
  exit 1
fi
#
ansible-playbook -i "$(inventory_path "$1")" "$(playbook_path redis-update-license.yaml)" -e "license=$2"
