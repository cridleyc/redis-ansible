# Redis Enterprise Role Payloads

This directory contains variable files used by `playbooks/redis-create-role.yaml`.

Use `re_roles` to create multiple Redis Enterprise roles:

```yaml
---
re_roles:
  - name: "App DB Viewer"
    management: "db_viewer"
  - name: "App DB Member"
    management: "db_member"
```

Use `redis_role` to create a single role:

```yaml
---
redis_role:
  name: "Operations User Manager"
  management: "user_manager"
```

Supported `management` values:

- `db_viewer`
- `db_member`
- `cluster_viewer`
- `cluster_member`
- `user_manager`
- `admin`

Run with the project inventory:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-create-role.yaml \
  -e @roles/custom-roles.yaml
```

If the inventory host is an alias such as `vm1`, pass the Redis Enterprise API host explicitly:

```bash
ansible-playbook -i inventory/single_nodes.yml playbooks/redis-create-role.yaml \
  -e @roles/custom-roles.yaml \
  -e redis_api_host=10.162.223.68
```

Use the API hostname or IP only. Do not include `https://` or `:9443` in `redis_api_host`.

This playbook runs with `connection: local` and disables `become`; role creation only uses the Redis Enterprise REST API and does not need SSH or sudo on the target node.
