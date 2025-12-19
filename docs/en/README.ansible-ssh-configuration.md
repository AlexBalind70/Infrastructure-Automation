# SSH Security Hardening

This module configures basic SSH security for servers.

The goal is to:
- reduce attack surface
- limit SSH access
- detect unauthorized access
- protect against bruteforce attempts

All configuration is applied automatically via Ansible.

---

## What is configured

### SSH access control
- SSH access is restricted by IP whitelist
- Only allowed IPs can connect to the server

### SSH login notifications
- Telegram notifications are sent on successful SSH logins
- Helps track who and when accessed the server

### Fail2Ban
- Protects SSH from bruteforce attacks
- Blocks IPs after multiple failed attempts
- Acts as an additional protection layer

### Fail2Ban notifications
- Telegram notifications on IP bans (optional)
- Disabled by default

---

## Important security recommendations

### Disable password authentication (recommended)
For important servers:
- disable SSH password login
- allow access **only via SSH keys**

Reason:
> The more access methods are enabled, the more attack vectors exist.

Based on practical experience, password authentication should be disabled
on all production and critical servers.

---

### SSH port
- Default SSH port (22) is heavily scanned
- Using a non-standard port reduces automated attacks

This is **not a replacement for security**, but a useful noise reduction.

---

### Fail2Ban notifications (real-world advice)

Fail2Ban ban notifications are **disabled by default**.

Reason:
- SSH bruteforce attempts happen constantly
- Notifications become noisy very fast
- Leads to alert fatigue

Recommendation:
- Enable ban notifications only for debugging or short periods
- Keep login notifications enabled

---

## Logging

- SSH logs are enabled and preserved
- Fail2Ban logs are available for audit
- Logs can be used for incident analysis

---

## Configuration files

Examples provided in the module:

- [sshd_config.example](../../src/ansible-ssh-configuration/ssh/sshd_config.example) # SSH daemon configuration
- [ssh.conf.example](../../src/ansible-ssh-configuration/ssh/fail2ban/jail.d/ssh.conf.example) # SSH client / access rules
- [ssh-notify.sh.example](../../src/ansible-ssh-configuration/ssh/ssh-notify.sh.example) # Telegram login notifications
- [telegram-ban.conf.example](../../src/ansible-ssh-configuration/ssh/fail2ban/telegram-ban.conf.example) # Fail2Ban Telegram integration


These files are templates and are applied via Ansible.

---

## How it works

1. SSH configuration is hardened
2. Access is restricted to allowed IPs
3. Fail2Ban monitors authentication failures
4. Telegram notifications report:
   - successful SSH logins
   - optional IP bans

---
### How to run
1. In the hosts file, add the target servers to the ssh_configuration group where SSH Configuration will be installed
2. Before running, make sure the Telegram bot token, chat ID, and topic ID are set in the files  
 ([ssh-notify.sh.example](../../src/ansible-ssh-configuration/ssh/ssh-notify.sh.example),  
[ssh.conf.example](../../src/ansible-ssh-configuration/ssh/fail2ban/jail.d/ssh.conf.example))
3. Run:

```bash
make ssh-conf-setup
```

Manual changes on servers are not recommended

### Design principles

- Minimal exposed surface
- Explicit access control
- Visibility over silent failures
- Safe to re-run (idempotent)











