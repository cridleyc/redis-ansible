#!/bin/bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_env.sh"

# This script will add an ldap mapping to the cluster pointed to by 
# $inventory_file.   The mapping is defined by a json file pointed
# to by the command line arg $2.  The format for this file can be 
# found in the Redis Enterprise API documentation:
#https://storage.googleapis.com/rlecrestapi/rest-html/http_rest_api.html#post--v1-ldap_mappings
#
if [[ $# -ne 2 ]]; then
  echo "*****************************************************************"
  echo "Usage: $0 <inventory_file> <ldap_mapping json file>"
  echo "note: the env var 're_inv' should be set to point to the subdir"
  echo "      containing <inventory_file>"
  echo "*****************************************************************"
  exit 1
fi
ansible-playbook -i "$(inventory_path "$1")" \
  "$(playbook_path redis-add-ldap-mapping.yaml)" -e @"$2"
