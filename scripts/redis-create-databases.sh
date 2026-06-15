#!/bin/bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_env.sh"

# this script can create multiple databases is one run using a properly 
#formatted input file - this file is fed in as an 'extra_var' and for this
# example the file is passed as a command line arg to the script
#
# arg 1 - inventory file
# arg 2 - database(s) yaml file
# an example file that creates four databases is "databases/databases.yaml"
# A single db can be created by using the yaml file with only one db in the list
# the example "redis-create-database.sh" expects a json payload - it is simpler
# to use this file with a single database - an example input file is 
# "databases/mikedb.yaml"
if [[ $# -lt 2 ]]; then
  echo "*****************************************************************"
  echo "Usage: $0 <inventory_file> <databases_yaml> [ansible args]"
  echo "*****************************************************************"
  exit 1
fi

ansible-playbook -i "$(inventory_path "$1")" \
  "$(playbook_path redis-create-databases.yaml)" -e @"$2" "${@:3}"
