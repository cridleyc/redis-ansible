# Playbook Usage Guide

This guide describes how to run the playbooks included in this Redis Enterprise Ansible 4.0 template. The examples assume that commands are run from the root of the `ansible_4` project.

```bash
cd ansible_4
```

## Conventions

- The wrappers in `scripts/` resolve paths using `scripts/_env.sh`.
- By default, the scripts look for inventories in `inventory/`.
- You can change the project base directory or the inventory directory with:

```bash
export re_ansbase="$PWD"
export re_inv="$PWD/inventory"
```

- For direct `ansible-playbook` commands, use:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/<playbook>.yaml
```

- When running commands through a script, use only the inventory filename:

```bash
./scripts/<script>.sh single_nodes.yml
```

- Playbooks that use `all[0]` perform the action on the first host in the inventory. That host must be a valid cluster node.
- Redis Enterprise API credentials are usually stored in `inventory/group_vars/<group>.yml` as `username` and `password`.
- The sample files in `databases/`, `localusers/`, `json/`, `crdbs/`, `certs/`, and `licenses/` are test templates. Adapt them before using them in customer environments.

## Base Variables

Common variables in `inventory/group_vars/all/main.yaml` or `inventory/group_vars/<group>.yml`:

```yaml
cluster_name: "redis-enterprise.example.internal"
username: "admin@example.com"
password: "<redis_api_password>"
re_url: "https://.../redislabs-<version>-<build>-<platform>.tar"
install_dir: /tmp/re_install
persistent_path: /var/opt/redislabs/persist
ephemeral_path: /var/opt/redislabs/tmp
flash_enabled: false
flash_path: /var/opt/redislabs/flash
```

Optional installer variables:

```yaml
re_install_answer_file: ""
re_socket_dir: ""
re_install_dir: ""
re_config_dir: ""
re_var_dir: ""
re_os_user: ""
re_os_group: ""
re_update_env_path: false
re_skip_dns_port_verification: false
re_install_extra_args: []
```

## Typical Provisioning Sequence

Typical workflow for a new cluster:

```bash
./scripts/redis-install.sh single_nodes.yml
./scripts/redis-create-cluster.sh single_nodes.yml
./scripts/redis-update-license.sh single_nodes.yml licenses/license
./scripts/redis-update-cluster.sh single_nodes.yml
./scripts/redis-create-role.sh single_nodes.yml roles/custom-roles.yaml
./scripts/redis-create-local-user.sh single_nodes.yml localusers/admin.yaml
./scripts/redis-ldap-update.sh single_nodes.yml json/ldap.json
./scripts/redis-add-ldap-mapping.sh single_nodes.yml json/ldapmap.json
./scripts/redis-update-certs.sh single_nodes.yml
./scripts/redis-create-databases.sh single_nodes.yml databases/mikedb.yaml
```

Combined workflow to install Redis Enterprise, create the cluster, and apply the license:

```bash
./scripts/redis-setup-singlenode-clstr.sh single_nodes.yml licenses/license
```

## Quick Reference

| Playbook | Purpose | Recommended Script |
| --- | --- | --- |
| `print_vars.yaml` | Print variables loaded from the inventory | `redis-print-vars` |
| `redis-print-version.yaml` | Print the Ansible bundle version | Direct command or `redis-print-version` |
| `redis-install.yaml` | Install Redis Enterprise on all nodes | `redis-install.sh` |
| `redis-create-cluster.yaml` | Create a cluster or join nodes to it | `redis-create-cluster.sh` |
| `redis-recover-cluster.yaml` | Recover a failed cluster from `ccs-redis.rdb` | Direct command |
| `redis-cluster-setup.yaml` | Install Redis Enterprise, create the cluster, and apply the license | `redis-setup-singlenode-clstr.sh` |
| `redis-provision-configure-cluster.yaml` | Complete provisioning with additional configuration | Direct command |
| `redis-update-license.yaml` | Apply or update the license | `redis-update-license.sh` |
| `redis-update-cluster.yaml` | Update cluster settings, such as email/SMTP | `redis-update-cluster.sh` |
| `redis-update-certs.yaml` | Update cluster certificates | `redis-update-certs.sh` |
| `redis-create-database.yaml` | Create or update a single BDB using `item` | Direct command |
| `redis-create-databases.yaml` | Create or update multiple BDBs from `re_databases` | `redis-create-databases.sh` |
| `redis-create-apat-bdbs.yaml` | Create APAT BDBs and a test replica | Direct command |
| `redis-update-database.yaml` | Update an existing BDB by name | `redis-update-database.sh` |
| `redis-delete-database.yaml` | Delete a BDB by UID | `redis-delete-database.sh` |
| `redis-delete-db-name.yaml` | Delete a BDB by name | `redis-delete-db-name.sh` |
| `redis-create-replica.yaml` | Create a replica-of database | `redis-create-replica.sh` |
| `redis-upgrade.yaml` | Perform a rolling upgrade of the cluster software | `redis-upgrade.sh` |
| `redis-upgrade-databases.yaml` | Upgrade BDB and CRDB versions and feature sets | `redis-upgrade-databases.sh` |
| `redis-create-crdb.yaml` | Create an Active-Active database | `redis-create-crdb.sh` |
| `redis-list-crdbs.yaml` | List CRDBs | `redis-list-crdbs.sh` |
| `redis-delete-crdb.yaml` | Delete a CRDB by GUID | `redis-delete-crdb.sh` |
| `redis-create-role.yaml` | Create Redis Enterprise roles | `redis-create-role.sh` |
| `redis-create-local-user.yaml` | Create a local user | `redis-create-local-user.sh` |
| `redis-update-local-user.yaml` | Update a local user | `redis-update-local-user.sh` |
| `redis-delete-local-user.yaml` | Delete a local user | `redis-delete-local-user.sh` |
| `redis-ldap-update.yaml` | Update LDAP configuration | `redis-ldap-update.sh` |
| `redis-add-ldap-mapping.yaml` | Create an LDAP-to-Redis-role mapping | `redis-add-ldap-mapping.sh` |
| `redis-list-ldap-mapping.yaml` | List LDAP mappings and roles | `redis-list-ldap-mapping.sh` |
| `redis-updt-ldap-mapping.yaml` | Update an existing LDAP mapping | `redis-updt-ldap-mapping.sh` |
| `redis-delete-ldap-mapping.yaml` | Delete an LDAP mapping | `redis-delete-ldap-mapping.sh` |
| `redis-set-quorum-node.yaml` | Configure a quorum-only node | `redis-quorum-node.sh` |
| `redis-quorum-node.yaml` | Legacy alias for the quorum role | Direct command |
| `redis-configure-load-balancer.yaml` | Configure proxy defaults and redirects for a load balancer | Direct command |
| `redis-uninstall.yaml` | Uninstall Redis Enterprise | `redis-uninstall.sh` |
| `systune.yaml` | Add an OS user to the `redislabs` group | Direct command |

## Playbooks

### `print_vars.yaml`

Prints the bundle version and the variables loaded for each host. Useful for validating the inventory and `group_vars`.

```bash
./scripts/redis-print-vars single_nodes.yml
```

Direct command:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/print_vars.yaml
```

### `redis-print-version.yaml`

Prints the bundle version using the `print_vers` role.

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-print-version.yaml
```

The `redis-print-version` script prints `rl_ansible_vers` directly from `inventory/group_vars/all/main.yaml`:

```bash
./scripts/redis-print-version
```

### `redis-install.yaml`

Installs Redis Enterprise on all nodes in the inventory. Uses `re_url` to download the package and supports optional installer variables.

```bash
./scripts/redis-install.sh single_nodes.yml
```

With additional arguments:

```bash
./scripts/redis-install.sh single_nodes.yml -e re_update_env_path=true
```

Direct command:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-install.yaml
```

### `redis-create-cluster.yaml`

Creates the cluster on the first host and joins the remaining nodes using the bootstrap API. Run this after installing Redis Enterprise.

```bash
./scripts/redis-create-cluster.sh single_nodes.yml
```

Direct command:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-create-cluster.yaml
```

Relevant variables:

```yaml
cluster_name: "redis-enterprise.example.internal"
username: "admin@example.com"
password: "<redis_api_password>"
persistent_path: /var/opt/redislabs/persist
ephemeral_path: /var/opt/redislabs/tmp
flash_enabled: false
```

For rack awareness, define `rack_id` for each host in `host_vars` or in the inventory.

### `redis-recover-cluster.yaml`

This playbook is based on the [Redis Enterprise cluster recovery guide](https://redis.io/docs/latest/operate/rs/clusters/cluster-recovery/).

Recovers a failed cluster from `ccs-redis.rdb`. With `serial: 1`, the first host in the inventory is recovered as `node_uid: 1`; each subsequent node joins in the same order, with `replace_node` set to its position: `2`, `3`, and so on.

This playbook is destructive and requires explicit confirmation. Before running it, install the same Redis Enterprise version on clean nodes, mount the persistent storage used for recovery, and verify that the configuration file exists on the first host. The role does not recover the databases; that step is performed after recovering the cluster.

```bash
ansible-playbook -i inventory/redis_nodes.yml playbooks/redis-recover-cluster.yaml \
  -e recover_cluster_confirm=true \
  -e recover_cluster_filename=/var/opt/redislabs/persist/ccs/ccs-redis.rdb \
  -K
```

To specify the internal IP address of the recovered node when it cannot be obtained from the inventory:

```bash
ansible-playbook -i inventory/redis_nodes.yml playbooks/redis-recover-cluster.yaml \
  -e recover_cluster_confirm=true \
  -e recover_cluster_member_ip=192.168.252.8 \
  -K
```

Optionally, you can adjust `recover_cluster_master_node_uid`, the `recover_cluster_persistent_path`, `recover_cluster_ephemeral_path`, and `recover_cluster_ccs_persistent_path` paths, and the rack or flash parameters defined in the role defaults. If the inventory defines `rack_id` or `second_rack_id` for each host, the role applies them to both the recovered node and each node that joins.

To define the values directly in `playbooks/redis-recover-cluster.yaml`, add a `vars` block to the play. Use variables with the `recover_cluster_` prefix to limit the changes to this recovery workflow:

```yaml
- name: Recover Redis Enterprise cluster and rejoin replacement nodes
  hosts: all
  order: inventory
  serial: 1
  gather_facts: false
  become: true
  vars:
    recover_cluster_confirm: true
    recover_cluster_filename: /mnt/recovery/ccs/ccs-redis.rdb
    recover_cluster_persistent_path: /mnt/recovery
    recover_cluster_ephemeral_path: /mnt/redis-tmp
    recover_cluster_ccs_persistent_path: /mnt/recovery/ccs
  roles:
    - recover_cluster
```

`recover_cluster_filename` is a path on the first Redis node, not on the Ansible server. If the file is initially on the Ansible controller, copy it to the recovery node first and retain read permissions for `redislabs`:

```bash
ansible 'ubuntu_nodes[0]' -i inventory/redis_nodes.yml -b -K \
  -m ansible.builtin.copy \
  -a 'src=./ccs-redis.rdb dest=/var/tmp/ccs-redis.rdb owner=redislabs group=redislabs mode=0640'
```

In that case, use `recover_cluster_filename: /var/tmp/ccs-redis.rdb`. You can still use `-e` when running the playbook; extra variables take precedence over values defined in the playbook.

### `redis-cluster-setup.yaml`

Runs installation, cluster creation, and license updates in a single playbook.

```bash
./scripts/redis-setup-singlenode-clstr.sh single_nodes.yml licenses/license
```

Direct command:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-cluster-setup.yaml \
  -e re_license=licenses/license
```

### `redis-provision-configure-cluster.yaml`

A combined playbook for full provisioning. Runs:

- `install`
- `create_cluster`
- `update_license`
- `create_local_user`
- `ldap_update`
- `add_ldap_mapping`
- `update_certs`
- `create_databases`

Example:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-provision-configure-cluster.yaml \
  -e re_license=licenses/license \
  -e @localusers/admin.yaml \
  -e @json/ldap.json \
  -e @json/ldapmap.json \
  -e @databases/mikedb.yaml \
  -e cert_dir="$PWD/certs"
```

Use it only after the required variable files have been adapted to the customer environment.

### `redis-update-license.yaml`

Applies or updates the cluster license.

```bash
./scripts/redis-update-license.sh single_nodes.yml licenses/license
```

Direct command:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-update-license.yaml \
  -e license=licenses/license
```

### `redis-update-cluster.yaml`

Updates cluster settings such as `email_from` and `smtp_host`.

```bash
./scripts/redis-update-cluster.sh single_nodes.yml
```

With overrides:

```bash
./scripts/redis-update-cluster.sh single_nodes.yml \
  -e email_from=redis-alerts@example.com \
  -e smtp_host=smtp.example.com
```

Direct command:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-update-cluster.yaml \
  -e email_from=redis-alerts@example.com \
  -e smtp_host=smtp.example.com
```

### `redis-update-certs.yaml`

Updates cluster certificates using subdirectories under `cert_dir`. By default, it uses:

- `certs/cm`
- `certs/api`
- `certs/proxy`
- `certs/syncer`
- `certs/metrics_exporter`

Each subdirectory must contain `ca.crt` and `ca.key`.

```bash
./scripts/redis-update-certs.sh single_nodes.yml
```

Direct command:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-update-certs.yaml \
  -e cert_dir="$PWD/certs"
```

### `redis-create-database.yaml`

Creates or updates a single database. This playbook uses the `item` variable, so it is usually simpler to use `redis-create-databases.yaml`. If you run it directly, pass `item` explicitly.

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-create-database.yaml \
  -e '{"item":{"name":"app-cache","memory_size":1073741824,"port":12000,"proxy_policy":"all-nodes","sharding":false,"replication":false}}'
```

### `redis-create-databases.yaml`

Creates or updates multiple databases from a `re_databases` list.

```bash
./scripts/redis-create-databases.sh single_nodes.yml databases/mikedb.yaml
```

With a file containing multiple databases:

```bash
./scripts/redis-create-databases.sh single_nodes.yml databases/databases.yaml
```

Direct command:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-create-databases.yaml \
  -e @databases/mikedb.yaml
```

Minimal payload example:

```yaml
re_databases:
  - name: "app-cache"
    memory_size: 1073741824
    port: 12000
    proxy_policy: all-nodes
    sharding: false
    replication: false
```

### `redis-create-apat-bdbs.yaml`

Creates APAT test databases, then creates a replica using the `create_replica_of` role.

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-create-apat-bdbs.yaml \
  -e @databases/apat-databases.yaml \
  -e @databases/replica_db.yaml \
  -e "src_db_name=sourcedb src_db_port=12003 rplc_db_name=replica-db"
```

Note: The APAT file may require a non-demo license due to the number of shards.

### `redis-update-database.yaml`

Updates an existing BDB by name.

```bash
./scripts/redis-update-database.sh single_nodes.yml Maple-syrup databases/update-maple.yaml
```

Direct command:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-update-database.yaml \
  -e bdb_name=Maple-syrup \
  -e @databases/update-maple.yaml
```

Payload example:

```yaml
bdb:
  name: "Maple-syrup"
  shards_count: 2
```

### `redis-delete-database.yaml`

Deletes a BDB by UID.

```bash
./scripts/redis-delete-database.sh single_nodes.yml 12345
```

Direct command:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-delete-database.yaml \
  -e bdb_id=12345
```

### `redis-delete-db-name.yaml`

Deletes a BDB by name. The name is case-sensitive.

```bash
./scripts/redis-delete-db-name.sh single_nodes.yml app-cache
```

Direct command:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-delete-db-name.yaml \
  -e db_name=app-cache
```

### `redis-create-replica.yaml`

Creates a `replica_of` database using an existing source BDB.

```bash
./scripts/redis-create-replica.sh single_nodes.yml databases/replica_db.yaml sourcedb 12003 replica-db 12006
```

Direct command:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-create-replica.yaml \
  -e @databases/replica_db.yaml \
  -e "src_db_name=sourcedb src_db_port=12003 rplc_db_name=replica-db rplc_db_port=12006"
```

Main variables:

```yaml
src_db_name: "sourcedb"
src_db_port: 12003
rplc_db_name: "replica-db"
rplc_db_port: 12006
replicadb:
  name: "replica-db"
  memory_size: 204800
  port: 12006
```

### `redis-upgrade.yaml`

Performs a rolling cluster upgrade. The first pass upgrades the master; the second upgrades the remaining nodes.

```bash
./scripts/redis-upgrade.sh single_nodes.yml
```

With a package override:

```bash
./scripts/redis-upgrade.sh single_nodes.yml \
  -e re_url=https://redis-enterprise-software-downloads.s3.amazonaws.com/8.0.16/redislabs-8.0.16-33-jammy-arm64.tar
```

Direct command:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-upgrade.yaml
```

### `redis-upgrade-databases.yaml`

Upgrades BDB and CRDB versions and feature sets after a cluster upgrade.

```bash
./scripts/redis-upgrade-databases.sh single_nodes.yml
```

Direct command:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-upgrade-databases.yaml
```

### `redis-create-crdb.yaml`

Creates an Active-Active database from a JSON/YAML payload in `crdbs/`. This playbook runs on `localhost` and requires API connection variables.

```bash
export clusterAPI="api.cluster.example.com:9443"
export clusterUser="admin@example.com"
export clusterPass="<redis_api_password>"
./scripts/redis-create-crdb.sh crdbs/crdb-demo.json global-cache
```

With optional placeholders:

```bash
export user1="admin@cluster-a.example.com"
export password1="<password_cluster_a>"
export user2="admin@cluster-b.example.com"
export password2="<password_cluster_b>"
./scripts/redis-create-crdb.sh crdbs/crdb-demo.json global-cache
```

Direct command:

```bash
ansible-playbook playbooks/redis-create-crdb.yaml \
  -e re_json=crdb-demo.json \
  -e dbname=global-cache \
  -e "clusterAPI=api.cluster.example.com:9443 clusterUser=admin@example.com clusterPass=<redis_api_password>"
```

If the file is not in `crdbs/`, pass an absolute path or define `crdb_files`.

### `redis-list-crdbs.yaml`

Lists CRDBs using API connection variables.

```bash
export clusterAPI="api.cluster.example.com:9443"
export clusterUser="admin@example.com"
export clusterPass="<redis_api_password>"
./scripts/redis-list-crdbs.sh
```

Direct command:

```bash
ansible-playbook playbooks/redis-list-crdbs.yaml \
  -e "clusterAPI=api.cluster.example.com:9443 clusterUser=admin@example.com clusterPass=<redis_api_password>"
```

### `redis-delete-crdb.yaml`

Deletes a CRDB by GUID.

```bash
export clusterAPI="api.cluster.example.com:9443"
export clusterUser="admin@example.com"
export clusterPass="<redis_api_password>"
./scripts/redis-delete-crdb.sh 12345678-90ab-cdef-1234-567890abcdef
```

Direct command:

```bash
ansible-playbook playbooks/redis-delete-crdb.yaml \
  -e "crdb_id=12345678-90ab-cdef-1234-567890abcdef clusterAPI=api.cluster.example.com:9443 clusterUser=admin@example.com clusterPass=<redis_api_password>"
```

### `redis-create-role.yaml`

Creates Redis Enterprise roles using `POST /v1/roles`. The playbook first queries `GET /v1/roles` and skips roles whose names already exist.

```bash
./scripts/redis-create-role.sh single_nodes.yml roles/custom-roles.yaml
```

Direct command:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-create-role.yaml \
  -e @roles/custom-roles.yaml
```

If the inventory uses aliases such as `vm1`, or if `ansible_host` is not a literal IP address or FQDN, pass the Redis Enterprise API endpoint explicitly:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-create-role.yaml \
  -e @roles/custom-roles.yaml \
  -e redis_api_host=10.162.223.68
```

The playbook runs with `connection: local` and disables `become` because it only uses the Redis Enterprise REST API; it does not require SSH or sudo to create roles.

Example for multiple roles:

```yaml
re_roles:
  - name: "App DB Viewer"
    management: "db_viewer"
  - name: "App DB Member"
    management: "db_member"
  - name: "Operations User Manager"
    management: "user_manager"
```

Example for a single role:

```yaml
redis_role:
  name: "Operations Admin"
  management: "admin"
```

Allowed values for `management`:

- `db_viewer`
- `db_member`
- `cluster_viewer`
- `cluster_member`
- `user_manager`
- `admin`

### `redis-create-local-user.yaml`

Creates a local Redis Enterprise user.

```bash
./scripts/redis-create-local-user.sh single_nodes.yml localusers/admin.yaml
```

Direct command:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-create-local-user.yaml \
  -e @localusers/admin.yaml
```

Payload example:

```yaml
user:
  email: "admin@example.com"
  password: "<user_password>"
  name: "Administrator"
  email_alerts: true
  role: "admin"
```

### `redis-update-local-user.yaml`

Updates an existing local user.

```bash
./scripts/redis-update-local-user.sh single_nodes.yml localusers/mikec-update.yaml
```

Direct command:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-update-local-user.yaml \
  -e @localusers/mikec-update.yaml
```

### `redis-delete-local-user.yaml`

Deletes a local user. The payload must include `user.name`.

```bash
./scripts/redis-delete-local-user.sh single_nodes.yml localusers/admin-del.yaml
```

Direct command:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-delete-local-user.yaml \
  -e @localusers/admin-del.yaml
```

### `redis-ldap-update.yaml`

Updates the cluster LDAP configuration.

```bash
./scripts/redis-ldap-update.sh single_nodes.yml json/ldap.json
```

Direct command:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-ldap-update.yaml \
  -e @json/ldap.json
```

### `redis-add-ldap-mapping.yaml`

Creates a mapping between an LDAP group and a Redis Enterprise role.

```bash
./scripts/redis-add-ldap-mapping.sh single_nodes.yml json/ldapmap.json
```

Direct command:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-add-ldap-mapping.yaml \
  -e @json/ldapmap.json
```

### `redis-list-ldap-mapping.yaml`

Lists LDAP mappings and available roles.

```bash
./scripts/redis-list-ldap-mapping.sh single_nodes.yml
```

Direct command:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-list-ldap-mapping.yaml
```

Use the output to obtain `map_uid` before updating or deleting a mapping.

### `redis-updt-ldap-mapping.yaml`

Updates an existing LDAP mapping.

```bash
./scripts/redis-updt-ldap-mapping.sh single_nodes.yml 1001 json/update_ldapmap.json
```

Direct command:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-updt-ldap-mapping.yaml \
  -e map_uid=1001 \
  -e @json/update_ldapmap.json
```

### `redis-delete-ldap-mapping.yaml`

Deletes an LDAP mapping by UID.

```bash
./scripts/redis-delete-ldap-mapping.sh single_nodes.yml 1001
```

Direct command:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-delete-ldap-mapping.yaml \
  -e map_uid=1001
```

### `redis-set-quorum-node.yaml`

Configures a node as quorum-only. If you do not pass `quorum_node`, the role runs `rladmin status nodes`, finds the first node whose total RAM is below `quorum_node_memory_threshold_gb`, and uses that ID automatically. The playbook sets `quorum_node_memory_threshold_gb: 2` by default.

```bash
./scripts/redis-quorum-node.sh single_nodes.yml
```

To specify the node manually:

```bash
./scripts/redis-quorum-node.sh single_nodes.yml 3
```

Direct command:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-set-quorum-node.yaml \
  -e quorum_node=3
```

With a custom threshold for automatic detection:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-set-quorum-node.yaml \
  -e quorum_node_memory_threshold_gb=4
```

### `redis-quorum-node.yaml`

Runs the same `quorum_node` role. Retained as an alias for compatibility.

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-quorum-node.yaml
```

### `redis-configure-load-balancer.yaml`

Configures the proxy defaults for new databases and enables redirect handling for a cluster deployed behind a load balancer. Runs once on the first host in the inventory and requires `sudo` privileges through `become`.

By default, it sets both proxy policies to `all-nodes` and `handle_redirects` to `enabled`. These defaults do not change the proxy policy of existing databases.

```bash
ansible-playbook -i inventory/redis_nodes.yml playbooks/redis-configure-load-balancer.yaml
```

To use a different proxy policy or disable redirects:

```bash
ansible-playbook -i inventory/redis_nodes.yml playbooks/redis-configure-load-balancer.yaml \
  -e redis_load_balancer_proxy_policy=all-master-shards \
  -e redis_load_balancer_handle_redirects=disabled
```

### `redis-uninstall.yaml`

Uninstalls Redis Enterprise from all nodes in the inventory using `rl_uninstall.sh`, if it exists.

```bash
./scripts/redis-uninstall.sh single_nodes.yml
```

Direct command:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-uninstall.yaml
```

Use with caution: it removes the Redis Enterprise installation from the selected nodes.

### `systune.yaml`

Adds an operating system user to the `redislabs` group.

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/systune.yaml \
  -e remuser=cridleyc
```

Note: The role uses `remuser`. The `runuser` and `rungroup` variables in the playbook are legacy defaults.

## Variable File Examples

### Database

```yaml
re_databases:
  - name: "app-cache"
    memory_size: 1073741824
    port: 12000
    proxy_policy: all-nodes
    sharding: false
    replication: true
```

### Local User

```yaml
user:
  email: "ops@example.com"
  password: "<user_password>"
  name: "Operations"
  email_alerts: true
  role: "admin"
```

### Redis Enterprise Roles

```yaml
re_roles:
  - name: "App DB Viewer"
    management: "db_viewer"
  - name: "Operations User Manager"
    management: "user_manager"
```

### LDAP Configuration

```yaml
ldap:
  uris:
    - "ldap://ldap.example.com:389"
  bind_dn: "cn=svc_redis,dc=example,dc=com"
  bind_pass: "<ldap_bind_password>"
  user_dn_template: "cn=%u,dc=example,dc=com"
  dn_group_attr: "memberOf"
```

### LDAP Mapping

```yaml
ldap_mapping:
  name: "Admins"
  dn: "OU=ops,DC=example,DC=com"
  email: "ops@example.com"
  role_uids: [1]
```

### CRDB Environment

```bash
export clusterAPI="api.cluster.example.com:9443"
export clusterUser="admin@example.com"
export clusterPass="<redis_api_password>"
```

## Validation

Before running playbooks in customer environments, validate the syntax:

```bash
ansible-playbook --syntax-check -i inventory/single_nodes.yml playbooks/redis-install.yaml
ansible-playbook --syntax-check -i inventory/single_nodes.yml playbooks/redis-create-cluster.yaml
```

General validation:

```bash
ansible-playbook --syntax-check -i inventory/single_nodes.yml playbooks/***.yaml
ansible-lint --profile min playbooks
```

Strict `ansible-lint` checks may report legacy style issues in this template. Treat those results as a cleanup backlog rather than an automatic execution blocker if the minimum profile and syntax checks pass.
