#!/bin/bash

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"

export re_ansbase="${re_ansbase:-$repo_root}"
export re_inv="${re_inv:-$repo_root/inventory}"

playbook_path() {
  printf '%s/playbooks/%s' "$re_ansbase" "$1"
}

inventory_path() {
  printf '%s/%s' "$re_inv" "$1"
}
