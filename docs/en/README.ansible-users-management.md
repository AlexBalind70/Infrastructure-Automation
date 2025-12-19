# Users Management

This module manages system users on servers using Ansible.

It supports:
- adding users
- removing users
- assigning sudo privileges
- managing SSH access

All behavior is controlled via variables in [secret.example.yml](../../src/ansible-users-management/vars/secret.example.yml).

---

## How it works

The playbook reads variables from a secret file and applies user state
to defined host groups.

There are only two possible states:
- user must exist on servers
- user must be absent from servers

No manual changes inside playbooks are required.

---

## Variables

All variables are defined in: [secret.example.yml](../../src/ansible-users-management/vars/secret.example.yml)


### Example:
```yaml
username: deploy

present_servers:
  - prod_servers
  - staging_servers

absent_servers:
  - old_servers
```

### Variables description

| Variable          | Description                                         |
| ----------------- | --------------------------------------------------- |
| `username`        | System username to manage                           |
| `present_servers` | Inventory groups where the user **must be present** |
| `absent_servers`  | Inventory groups where the user **must be removed** |


## Behavior rules
If a server is in `present_servers`:

- user is created
- SSH access is enabled
- sudo rights are granted (if configured)

If a server is in `absent_servers` user is removed and home directory is deleted

If a server is in neither list, no changes are applied


## Running the playbook

```bash
make users_management.yml
```


## Important notes
- Do not edit playbooks to manage users
- All changes must go through variables
- One playbook run = single source of truth
- Safe to re-run multiple times (idempotent)