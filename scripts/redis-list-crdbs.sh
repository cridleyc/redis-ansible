#!/bin/bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_env.sh"

: "${clusterAPI:?Set clusterAPI before running this script}"
: "${clusterUser:?Set clusterUser before running this script}"
: "${clusterPass:?Set clusterPass before running this script}"

ansible-playbook "$(playbook_path redis-list-crdbs.yaml)" \
  -e "clusterAPI=$clusterAPI clusterUser=$clusterUser clusterPass=$clusterPass" \
  "$@"
