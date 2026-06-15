#!/bin/bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_env.sh"

# For these examples, the 'certs/' subdirectory contains example certs
# These certificates are self-signed and are not intended for use.  They
# provide valid examples for the playbooks but are otherwise unsuitable for use
# the following sub directories hold certs for each of the following uses:
# api, cm, metrics_exporter, syncer, proxy
# in each of these subdirs, a ca.key and a ca.crt file must exist
# For clarity, the 'cert_dir' is declared as an extra_var in this script.
# In practice, you probably want to include this as a group_var for each cluster
#
if [[ $# -lt 1 ]]; then
  echo "*****************************************************************"
  echo "Usage: $0 <inventory_file>"
  echo "note: the env var 're_inv' should be set to point to the subdir"
  echo "      containing <inventory_file>"
  echo "*****************************************************************"
  exit 1
fi
ansible-playbook -i "$(inventory_path "$1")" "$(playbook_path redis-update-certs.yaml)" \
  -e "cert_dir=$re_ansbase/certs"
