#!/bin/bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_env.sh"

# Update database config using input yaml file - this uses Redis API
# PUT /v1/bdbs - no error checking is done in Ansible
# the add '-vvvv' after 'ansible-playbook' below to see the output of the 
# API call for troubleshooting
#
# command line args:
# arg 1 - inventory file
# arg 2 - database name
# arg 3 - database yaml file
if [[ $# -lt 3 ]]; then
  echo "*****************************************************************"
  echo "Usage: $0 <inventory_file> <database_name> <database_yaml> [ansible args]"
  echo "*****************************************************************"
  exit 1
fi

ansible-playbook -i "$(inventory_path "$1")" \
  "$(playbook_path redis-update-database.yaml)" -e "bdb_name=$2" -e @"$3" "${@:4}"
