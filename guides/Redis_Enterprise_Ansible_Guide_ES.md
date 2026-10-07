# Guia de Uso de Playbooks

Esta guia describe como ejecutar los playbooks incluidos en este template de Redis Enterprise Ansible 4.0. Los ejemplos asumen que se ejecutan desde la raiz del proyecto `ansible_4`.

```bash
cd ansible_4
```

## Convenciones

- Los wrappers en `scripts/` resuelven rutas usando `scripts/_env.sh`.
- Por defecto, los scripts buscan inventarios dentro de `inventory/`.
- Puedes cambiar la base del proyecto o el directorio de inventarios con:

```bash
export re_ansbase="$PWD"
export re_inv="$PWD/inventory"
```

- En comandos directos con `ansible-playbook`, usa:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/<playbook>.yaml
```

- En comandos via script, usa solo el nombre del inventario:

```bash
./scripts/<script>.sh single_nodes.yml
```

- Los playbooks que usan `all[0]` ejecutan la accion contra el primer host del inventario. Ese host debe ser un nodo valido del cluster.
- Las credenciales de la API de Redis Enterprise normalmente viven en `inventory/group_vars/<grupo>.yml` como `username` y `password`.
- Los archivos de ejemplo en `databases/`, `localusers/`, `json/`, `crdbs/`, `certs/` y `licenses/` son templates de prueba. Ajustalos antes de usarlos contra clientes.

## Variables Base

Variables comunes en `inventory/group_vars/all/main.yaml` o `inventory/group_vars/<grupo>.yml`:

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

Variables opcionales del instalador:

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

## Orden Comun de Provisionamiento

Flujo tipico para un cluster nuevo:

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

Flujo compacto para instalar, crear cluster y aplicar licencia:

```bash
./scripts/redis-setup-singlenode-clstr.sh single_nodes.yml licenses/license
```

## Resumen Rapido

| Playbook | Proposito | Script recomendado |
| --- | --- | --- |
| `print_vars.yaml` | Imprimir variables cargadas desde inventario | `redis-print-vars` |
| `redis-print-version.yaml` | Imprimir version del bundle Ansible | comando directo o `redis-print-version` |
| `redis-install.yaml` | Instalar Redis Enterprise en todos los nodos | `redis-install.sh` |
| `redis-create-cluster.yaml` | Crear o unir nodos al cluster | `redis-create-cluster.sh` |
| `redis-recover-cluster.yaml` | Recuperar un cluster fallido desde `ccs-redis.rdb` | comando directo |
| `redis-cluster-setup.yaml` | Instalar, crear cluster y aplicar licencia | `redis-setup-singlenode-clstr.sh` |
| `redis-provision-configure-cluster.yaml` | Provisionamiento completo con configuracion adicional | comando directo |
| `redis-update-license.yaml` | Aplicar o actualizar licencia | `redis-update-license.sh` |
| `redis-update-cluster.yaml` | Actualizar settings de cluster, como email/SMTP | `redis-update-cluster.sh` |
| `redis-update-certs.yaml` | Actualizar certificados del cluster | `redis-update-certs.sh` |
| `redis-create-database.yaml` | Crear o actualizar una BDB individual usando `item` | comando directo |
| `redis-create-databases.yaml` | Crear o actualizar multiples BDBs desde `re_databases` | `redis-create-databases.sh` |
| `redis-create-apat-bdbs.yaml` | Crear BDBs APAT y replica de prueba | comando directo |
| `redis-update-database.yaml` | Actualizar una BDB existente por nombre | `redis-update-database.sh` |
| `redis-delete-database.yaml` | Eliminar BDB por UID | `redis-delete-database.sh` |
| `redis-delete-db-name.yaml` | Eliminar BDB por nombre | `redis-delete-db-name.sh` |
| `redis-create-replica.yaml` | Crear database replica-of | `redis-create-replica.sh` |
| `redis-upgrade.yaml` | Upgrade rolling del software del cluster | `redis-upgrade.sh` |
| `redis-upgrade-databases.yaml` | Upgrade de versiones/featureset de BDBs y CRDBs | `redis-upgrade-databases.sh` |
| `redis-create-crdb.yaml` | Crear Active-Active database | `redis-create-crdb.sh` |
| `redis-list-crdbs.yaml` | Listar CRDBs | `redis-list-crdbs.sh` |
| `redis-delete-crdb.yaml` | Eliminar CRDB por GUID | `redis-delete-crdb.sh` |
| `redis-create-role.yaml` | Crear roles de Redis Enterprise | `redis-create-role.sh` |
| `redis-create-local-user.yaml` | Crear usuario local | `redis-create-local-user.sh` |
| `redis-update-local-user.yaml` | Actualizar usuario local | `redis-update-local-user.sh` |
| `redis-delete-local-user.yaml` | Eliminar usuario local | `redis-delete-local-user.sh` |
| `redis-ldap-update.yaml` | Actualizar configuracion LDAP | `redis-ldap-update.sh` |
| `redis-add-ldap-mapping.yaml` | Crear mapping LDAP a rol Redis | `redis-add-ldap-mapping.sh` |
| `redis-list-ldap-mapping.yaml` | Listar mappings LDAP y roles | `redis-list-ldap-mapping.sh` |
| `redis-updt-ldap-mapping.yaml` | Actualizar mapping LDAP existente | `redis-updt-ldap-mapping.sh` |
| `redis-delete-ldap-mapping.yaml` | Eliminar mapping LDAP | `redis-delete-ldap-mapping.sh` |
| `redis-set-quorum-node.yaml` | Configurar nodo quorum-only | `redis-quorum-node.sh` |
| `redis-quorum-node.yaml` | Alias legacy del rol quorum | comando directo |
| `redis-configure-load-balancer.yaml` | Configurar defaults de proxy y redirects para un load balancer | comando directo |
| `redis-uninstall.yaml` | Desinstalar Redis Enterprise | `redis-uninstall.sh` |
| `systune.yaml` | Agregar usuario OS al grupo `redislabs` | comando directo |

## Playbooks

### `print_vars.yaml`

Imprime la version del bundle y las variables cargadas para cada host. Util para validar inventario y `group_vars`.

```bash
./scripts/redis-print-vars single_nodes.yml
```

Comando directo:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/print_vars.yaml
```

### `redis-print-version.yaml`

Imprime la version del bundle usando el rol `print_vers`.

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-print-version.yaml
```

El script `redis-print-version` imprime directamente `rl_ansible_vers` desde `inventory/group_vars/all/main.yaml`:

```bash
./scripts/redis-print-version
```

### `redis-install.yaml`

Instala Redis Enterprise en todos los nodos del inventario. Usa `re_url` para descargar el paquete y variables opcionales del instalador.

```bash
./scripts/redis-install.sh single_nodes.yml
```

Con argumentos adicionales:

```bash
./scripts/redis-install.sh single_nodes.yml -e re_update_env_path=true
```

Comando directo:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-install.yaml
```

### `redis-create-cluster.yaml`

Crea el cluster en el primer host y une los demas nodos usando la API de bootstrap. Debe ejecutarse despues de instalar Redis Enterprise.

```bash
./scripts/redis-create-cluster.sh single_nodes.yml
```

Comando directo:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-create-cluster.yaml
```

Variables relevantes:

```yaml
cluster_name: "redis-enterprise.example.internal"
username: "admin@example.com"
password: "<redis_api_password>"
persistent_path: /var/opt/redislabs/persist
ephemeral_path: /var/opt/redislabs/tmp
flash_enabled: false
```

Para rack awareness, define `rack_id` por host en `host_vars` o inventario.

### `redis-recover-cluster.yaml`
# Playbook basada en el instructivo: https://redis.io/docs/latest/operate/rs/clusters/cluster-recovery/

Recupera un cluster fallido a partir de `ccs-redis.rdb`. Con `serial: 1`, el primer host del inventario se recupera como `node_uid: 1`; cada nodo posterior se une en el mismo orden con `replace_node` igual a su posicion: `2`, `3`, y asi sucesivamente.

Este playbook es destructivo y requiere confirmacion explicita. Antes de ejecutarlo, instala la misma version de Redis Enterprise en nodos limpios, monta el almacenamiento persistente de recuperacion y verifica que el archivo de configuracion exista en el primer host. El rol no recupera las bases de datos; ese paso se realiza despues de recuperar el cluster.

```bash
ansible-playbook -i inventory/redis_nodes.yml playbooks/redis-recover-cluster.yaml \
  -e recover_cluster_confirm=true \
  -e recover_cluster_filename=/var/opt/redislabs/persist/ccs/ccs-redis.rdb \
  -K
```

Para indicar la IP interna del nodo recuperado cuando no se puede obtener desde el inventario:

```bash
ansible-playbook -i inventory/redis_nodes.yml playbooks/redis-recover-cluster.yaml \
  -e recover_cluster_confirm=true \
  -e recover_cluster_member_ip=192.168.252.8 \
  -K
```

Opcionalmente puedes adaptar `recover_cluster_master_node_uid`, los paths `recover_cluster_persistent_path`, `recover_cluster_ephemeral_path`, `recover_cluster_ccs_persistent_path`, y los parametros de rack o flash definidos en los defaults del rol. Si el inventario define `rack_id` o `second_rack_id` por host, el rol los aplica tanto al nodo recuperado como a cada nodo unido.

Para definir los valores directamente en `playbooks/redis-recover-cluster.yaml`, agrega un bloque `vars` al play. Usa las variables con prefijo `recover_cluster_` para limitar el cambio a este flujo de recuperacion:

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

`recover_cluster_filename` es una ruta en el primer nodo Redis, no en el servidor Ansible. Si el archivo esta inicialmente en el controlador Ansible, copialo primero al nodo de recuperacion y conserva permisos de lectura para `redislabs`:

```bash
ansible 'ubuntu_nodes[0]' -i inventory/redis_nodes.yml -b -K \
  -m ansible.builtin.copy \
  -a 'src=./ccs-redis.rdb dest=/var/tmp/ccs-redis.rdb owner=redislabs group=redislabs mode=0640'
```

En ese caso, utiliza `recover_cluster_filename: /var/tmp/ccs-redis.rdb`. Puedes seguir usando `-e` al ejecutar el playbook; las variables extra tienen prioridad sobre los valores definidos en el playbook.

### `redis-cluster-setup.yaml`

Ejecuta instalacion, creacion del cluster y actualizacion de licencia en un solo playbook.

```bash
./scripts/redis-setup-singlenode-clstr.sh single_nodes.yml licenses/license
```

Comando directo:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-cluster-setup.yaml \
  -e re_license=licenses/license
```

### `redis-provision-configure-cluster.yaml`

Playbook compuesto para provisionamiento completo. Ejecuta:

- `install`
- `create_cluster`
- `update_license`
- `create_local_user`
- `ldap_update`
- `add_ldap_mapping`
- `update_certs`
- `create_databases`

Ejemplo:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-provision-configure-cluster.yaml \
  -e re_license=licenses/license \
  -e @localusers/admin.yaml \
  -e @json/ldap.json \
  -e @json/ldapmap.json \
  -e @databases/mikedb.yaml \
  -e cert_dir="$PWD/certs"
```

Usalo solo cuando los archivos de variables requeridos ya esten adaptados al cliente.

### `redis-update-license.yaml`

Aplica o actualiza la licencia del cluster.

```bash
./scripts/redis-update-license.sh single_nodes.yml licenses/license
```

Comando directo:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-update-license.yaml \
  -e license=licenses/license
```

### `redis-update-cluster.yaml`

Actualiza settings de cluster como `email_from` y `smtp_host`.

```bash
./scripts/redis-update-cluster.sh single_nodes.yml
```

Con overrides:

```bash
./scripts/redis-update-cluster.sh single_nodes.yml \
  -e email_from=redis-alerts@example.com \
  -e smtp_host=smtp.example.com
```

Comando directo:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-update-cluster.yaml \
  -e email_from=redis-alerts@example.com \
  -e smtp_host=smtp.example.com
```

### `redis-update-certs.yaml`

Actualiza certificados del cluster usando subdirectorios bajo `cert_dir`. Por defecto usa:

- `certs/cm`
- `certs/api`
- `certs/proxy`
- `certs/syncer`
- `certs/metrics_exporter`

Cada subdirectorio debe contener `ca.crt` y `ca.key`.

```bash
./scripts/redis-update-certs.sh single_nodes.yml
```

Comando directo:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-update-certs.yaml \
  -e cert_dir="$PWD/certs"
```

### `redis-create-database.yaml`

Crea o actualiza una base de datos individual. Este playbook usa la variable `item`, por lo que normalmente es mas simple usar `redis-create-databases.yaml`. Si lo ejecutas directo, pasa `item` explicitamente.

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-create-database.yaml \
  -e '{"item":{"name":"app-cache","memory_size":1073741824,"port":12000,"proxy_policy":"all-nodes","sharding":false,"replication":false}}'
```

### `redis-create-databases.yaml`

Crea o actualiza multiples bases de datos desde una lista `re_databases`.

```bash
./scripts/redis-create-databases.sh single_nodes.yml databases/mikedb.yaml
```

Con archivo de multiples bases:

```bash
./scripts/redis-create-databases.sh single_nodes.yml databases/databases.yaml
```

Comando directo:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-create-databases.yaml \
  -e @databases/mikedb.yaml
```

Ejemplo minimo de payload:

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

Crea bases de datos de prueba APAT y luego crea una replica usando el rol `create_replica_of`.

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-create-apat-bdbs.yaml \
  -e @databases/apat-databases.yaml \
  -e @databases/replica_db.yaml \
  -e "src_db_name=sourcedb src_db_port=12003 rplc_db_name=replica-db"
```

Nota: el archivo APAT puede requerir licencia no demo por cantidad de shards.

### `redis-update-database.yaml`

Actualiza una BDB existente por nombre.

```bash
./scripts/redis-update-database.sh single_nodes.yml Maple-syrup databases/update-maple.yaml
```

Comando directo:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-update-database.yaml \
  -e bdb_name=Maple-syrup \
  -e @databases/update-maple.yaml
```

Ejemplo de payload:

```yaml
bdb:
  name: "Maple-syrup"
  shards_count: 2
```

### `redis-delete-database.yaml`

Elimina una BDB por UID.

```bash
./scripts/redis-delete-database.sh single_nodes.yml 12345
```

Comando directo:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-delete-database.yaml \
  -e bdb_id=12345
```

### `redis-delete-db-name.yaml`

Elimina una BDB por nombre. El nombre es case-sensitive.

```bash
./scripts/redis-delete-db-name.sh single_nodes.yml app-cache
```

Comando directo:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-delete-db-name.yaml \
  -e db_name=app-cache
```

### `redis-create-replica.yaml`

Crea una database `replica_of` usando una BDB fuente existente.

```bash
./scripts/redis-create-replica.sh single_nodes.yml databases/replica_db.yaml sourcedb 12003 replica-db 12006
```

Comando directo:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-create-replica.yaml \
  -e @databases/replica_db.yaml \
  -e "src_db_name=sourcedb src_db_port=12003 rplc_db_name=replica-db rplc_db_port=12006"
```

Variables principales:

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

Realiza upgrade rolling del cluster. La primera pasada actualiza el master; la segunda actualiza los nodos restantes.

```bash
./scripts/redis-upgrade.sh single_nodes.yml
```

Con override de paquete:

```bash
./scripts/redis-upgrade.sh single_nodes.yml \
  -e re_url=https://redis-enterprise-software-downloads.s3.amazonaws.com/8.0.16/redislabs-8.0.16-33-jammy-arm64.tar
```

Comando directo:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-upgrade.yaml
```

### `redis-upgrade-databases.yaml`

Actualiza versiones/featureset de BDBs y CRDBs despues de un upgrade de cluster.

```bash
./scripts/redis-upgrade-databases.sh single_nodes.yml
```

Comando directo:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-upgrade-databases.yaml
```

### `redis-create-crdb.yaml`

Crea una Active-Active database desde un payload JSON/YAML en `crdbs/`. Este playbook corre en `localhost` y requiere variables de conexion a la API.

```bash
export clusterAPI="api.cluster.example.com:9443"
export clusterUser="admin@example.com"
export clusterPass="<redis_api_password>"
./scripts/redis-create-crdb.sh crdbs/crdb-demo.json global-cache
```

Con placeholders opcionales:

```bash
export user1="admin@cluster-a.example.com"
export password1="<password_cluster_a>"
export user2="admin@cluster-b.example.com"
export password2="<password_cluster_b>"
./scripts/redis-create-crdb.sh crdbs/crdb-demo.json global-cache
```

Comando directo:

```bash
ansible-playbook playbooks/redis-create-crdb.yaml \
  -e re_json=crdb-demo.json \
  -e dbname=global-cache \
  -e "clusterAPI=api.cluster.example.com:9443 clusterUser=admin@example.com clusterPass=<redis_api_password>"
```

Si el archivo no esta en `crdbs/`, pasa ruta absoluta o define `crdb_files`.

### `redis-list-crdbs.yaml`

Lista CRDBs usando variables de conexion a la API.

```bash
export clusterAPI="api.cluster.example.com:9443"
export clusterUser="admin@example.com"
export clusterPass="<redis_api_password>"
./scripts/redis-list-crdbs.sh
```

Comando directo:

```bash
ansible-playbook playbooks/redis-list-crdbs.yaml \
  -e "clusterAPI=api.cluster.example.com:9443 clusterUser=admin@example.com clusterPass=<redis_api_password>"
```

### `redis-delete-crdb.yaml`

Elimina una CRDB por GUID.

```bash
export clusterAPI="api.cluster.example.com:9443"
export clusterUser="admin@example.com"
export clusterPass="<redis_api_password>"
./scripts/redis-delete-crdb.sh 12345678-90ab-cdef-1234-567890abcdef
```

Comando directo:

```bash
ansible-playbook playbooks/redis-delete-crdb.yaml \
  -e "crdb_id=12345678-90ab-cdef-1234-567890abcdef clusterAPI=api.cluster.example.com:9443 clusterUser=admin@example.com clusterPass=<redis_api_password>"
```

### `redis-create-role.yaml`

Crea roles de Redis Enterprise usando `POST /v1/roles`. El playbook primero consulta `GET /v1/roles` y omite roles que ya existan por nombre.

```bash
./scripts/redis-create-role.sh single_nodes.yml roles/custom-roles.yaml
```

Comando directo:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-create-role.yaml \
  -e @roles/custom-roles.yaml
```

Si el inventario usa alias como `vm1`, o si `ansible_host` no es una IP/FQDN literal, pasa el endpoint de la API de Redis Enterprise explicitamente:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-create-role.yaml \
  -e @roles/custom-roles.yaml \
  -e redis_api_host=10.162.223.68
```

El playbook corre con `connection: local` y desactiva `become` porque solo usa la API REST de Redis Enterprise; no necesita SSH ni sudo para crear roles.

Ejemplo para multiples roles:

```yaml
re_roles:
  - name: "App DB Viewer"
    management: "db_viewer"
  - name: "App DB Member"
    management: "db_member"
  - name: "Operations User Manager"
    management: "user_manager"
```

Ejemplo para un solo role:

```yaml
redis_role:
  name: "Operations Admin"
  management: "admin"
```

Valores permitidos para `management`:

- `db_viewer`
- `db_member`
- `cluster_viewer`
- `cluster_member`
- `user_manager`
- `admin`

### `redis-create-local-user.yaml`

Crea un usuario local de Redis Enterprise.

```bash
./scripts/redis-create-local-user.sh single_nodes.yml localusers/admin.yaml
```

Comando directo:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-create-local-user.yaml \
  -e @localusers/admin.yaml
```

Ejemplo de payload:

```yaml
user:
  email: "admin@example.com"
  password: "<user_password>"
  name: "Administrator"
  email_alerts: true
  role: "admin"
```

### `redis-update-local-user.yaml`

Actualiza un usuario local existente.

```bash
./scripts/redis-update-local-user.sh single_nodes.yml localusers/mikec-update.yaml
```

Comando directo:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-update-local-user.yaml \
  -e @localusers/mikec-update.yaml
```

### `redis-delete-local-user.yaml`

Elimina un usuario local. El payload debe incluir `user.name`.

```bash
./scripts/redis-delete-local-user.sh single_nodes.yml localusers/admin-del.yaml
```

Comando directo:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-delete-local-user.yaml \
  -e @localusers/admin-del.yaml
```

### `redis-ldap-update.yaml`

Actualiza configuracion LDAP del cluster.

```bash
./scripts/redis-ldap-update.sh single_nodes.yml json/ldap.json
```

Comando directo:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-ldap-update.yaml \
  -e @json/ldap.json
```

### `redis-add-ldap-mapping.yaml`

Crea un mapping entre grupo LDAP y rol Redis Enterprise.

```bash
./scripts/redis-add-ldap-mapping.sh single_nodes.yml json/ldapmap.json
```

Comando directo:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-add-ldap-mapping.yaml \
  -e @json/ldapmap.json
```

### `redis-list-ldap-mapping.yaml`

Lista mappings LDAP y roles disponibles.

```bash
./scripts/redis-list-ldap-mapping.sh single_nodes.yml
```

Comando directo:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-list-ldap-mapping.yaml
```

Usa la salida para obtener `map_uid` antes de actualizar o eliminar un mapping.

### `redis-updt-ldap-mapping.yaml`

Actualiza un mapping LDAP existente.

```bash
./scripts/redis-updt-ldap-mapping.sh single_nodes.yml 1001 json/update_ldapmap.json
```

Comando directo:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-updt-ldap-mapping.yaml \
  -e map_uid=1001 \
  -e @json/update_ldapmap.json
```

### `redis-delete-ldap-mapping.yaml`

Elimina un mapping LDAP por UID.

```bash
./scripts/redis-delete-ldap-mapping.sh single_nodes.yml 1001
```

Comando directo:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-delete-ldap-mapping.yaml \
  -e map_uid=1001
```

### `redis-set-quorum-node.yaml`

Configura un nodo como quorum-only. Si no pasas `quorum_node`, el rol ejecuta `rladmin status nodes`, busca el primer nodo con RAM total menor a `quorum_node_memory_threshold_gb` y usa ese ID automaticamente. El playbook define `quorum_node_memory_threshold_gb: 2` por defecto.

```bash
./scripts/redis-quorum-node.sh single_nodes.yml
```

Para indicar el nodo manualmente:

```bash
./scripts/redis-quorum-node.sh single_nodes.yml 3
```

Comando directo:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-set-quorum-node.yaml \
  -e quorum_node=3
```

Con umbral personalizado para deteccion automatica:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-set-quorum-node.yaml \
  -e quorum_node_memory_threshold_gb=4
```

### `redis-quorum-node.yaml`

Ejecuta el mismo rol `quorum_node`. Se mantiene como alias/compatibilidad.

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-quorum-node.yaml
```

### `redis-configure-load-balancer.yaml`

Configura los defaults de proxy para bases de datos nuevas y habilita el manejo de redirects para un cluster desplegado detras de un load balancer. Se ejecuta una sola vez en el primer host del inventario y requiere privilegios de `sudo` mediante `become`.

Por defecto, configura ambas politicas de proxy como `all-nodes` y `handle_redirects` como `enabled`. Estos defaults no cambian la politica de proxy de bases de datos existentes.

```bash
ansible-playbook -i inventory/redis_nodes.yml playbooks/redis-configure-load-balancer.yaml
```

Para usar otra politica de proxy o desactivar redirects:

```bash
ansible-playbook -i inventory/redis_nodes.yml playbooks/redis-configure-load-balancer.yaml \
  -e redis_load_balancer_proxy_policy=all-master-shards \
  -e redis_load_balancer_handle_redirects=disabled
```

### `redis-uninstall.yaml`

Desinstala Redis Enterprise de todos los nodos del inventario usando `rl_uninstall.sh` si existe.

```bash
./scripts/redis-uninstall.sh single_nodes.yml
```

Comando directo:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-uninstall.yaml
```

Usalo con cuidado: elimina la instalacion de Redis Enterprise de los nodos seleccionados.

### `systune.yaml`

Agrega un usuario del sistema operativo al grupo `redislabs`.

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/systune.yaml \
  -e remuser=cridleyc
```

Nota: el role consume `remuser`. Las variables `runuser` y `rungroup` en el playbook son defaults heredados.

## Ejemplos de Archivos de Variables

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

### LDAP Config

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

## Validacion

Antes de correr contra clientes, valida sintaxis:

```bash
ansible-playbook --syntax-check -i inventory/single_nodes.yml playbooks/redis-install.yaml
ansible-playbook --syntax-check -i inventory/single_nodes.yml playbooks/redis-create-cluster.yaml
```

Validacion general:

```bash
ansible-playbook --syntax-check -i inventory/single_nodes.yml playbooks/*.yaml
ansible-lint --profile min playbooks
```

`ansible-lint` estricto puede reportar deuda heredada de estilo en este template. Usa esos resultados como backlog de limpieza, no como bloqueo automatico de ejecucion si el perfil minimo y el syntax check pasan.
