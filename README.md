<p align="right">
  <a href="docs/ru/README.ru.md">RU</a> |
  <a href="README.md">EN</a>
</p>

# Infrastructure-Automation
The repository contains Ansible playbooks and auxiliary tools for automating server and infrastructure configuration


**Main tasks:**
  - [Set up Master Proxy](#master-proxy)
  - [Install Docker and Docker Compose](#docker-install)
  - [Users management](#users-management)
  - [SSH Security Hardening](#ssh-security-hardening)
  - [Nginx Setup](#nginx-setup)
  - [NVIDIA Driver and Docker GPU Setup](#nvidia-gpu-driver-installation)
  - [GitLab Deployment](#gitlab-deployment)


## Repository structure

```text
src/
├── ansible-docker-install/         # Docker installation and configuration
├── ansible-gitlab                  # GitLab installation and maintenance
├── ansible-master-proxy            # Master proxy
├── ansible-gpu-setup               # NVIDIA Driver and Docker GPU Setup
├── ansible-nginx-setup             # Nginx setup
├── ansible-ssh-configuration       # SSH Security Hardening
├── ansible-users-management        # Users management
└── keys                            # SSH keys for ansible
.env.example                   
add_ansible_keys.sh
ansible.cfg                         # Ansible configuration file
docker-compose.yml
Dockerfile
Makefile
setup-project.sh                    # Script for setup project
```
> 👉 Detailed documentation is available in [docs/](docs/ru)

## Requirements

You need:

- Linux / macOS / Windows
- Docker
- Docker Compose
- Git
- SSH-доступ к серверам


## Getting started

### 1. Clone the repository
```bash
git clone <repository-url>
cd server-setup
```

### 2. Create `.env`

Create a `.env` file based on the example at [.env.example](../../.env.example):

```commandline
cp .env.example .env
```
Then fill in the variables.


### 3. Project initialization

```commandline
make setup-project
```
> ⚠️ _This command is meant to run once.
If you run it again, the files will be restored._


---

## Initial server setup (very important)

### Server preparation

Before running Ansible, you must set up SSH access.

### Steps:

1. Add the public SSH key from `keys/ssh-public-key`  
   to `~/.ssh/authorized_keys` for the `root` user on the server

2. Edit the `add_ansible_keys.sh`, script and set:
   - server IP addresses
   - root passwords (used only for initial access)

3. Run the script:
```bash
bash add_ansible_keys.sh
```

---
## Running Ansible via Docker Compose (required)
All playbooks are run only through `make`. Ansible itself runs inside a container.
This is intentional. No Ansible, sshpass, or extra packages on the host machine.
Everyone gets the same environment.

### How it works

1. **docker-compose.yml** starts the `ansible` service
2. The Dockerfile builds an image with Ansible and copies `src/` into the container
3. The Makefile runs Ansible / ansible-playbook via `docker compose run`

## Running playbooks

Example: user management playbook.

```bash
make users_management.yml
```
After this, Ansible connects to servers using SSH keys. No password login.

---

## Docker Install
Docker is installed and configured automatically via Ansible.

- Docker Engine - container runtime
- Docker Compose - service management
- Docker daemon configuration via `daemon.json`
- Log rotation enabled
- BuildKit enabled

> ⚠️ Important  
> Use Docker versions supported by the target OS.
> Set the correct versions in Ansible variables [Ansible](../../src/ansible-docker-install/playbooks/docker-install.yml).

Detailed documentation and run instructions:
📄 [README.md](docs/en/README.ansible-docker-install.md)

### Run
```bash
make docker-setup
```

---

## Master Proxy

The project uses a **Master Proxy** based on Nginx.
It routes HTTP/HTTPS traffic to multiple internal servers using a single public IP.

> ⚠️ Important  
> The router must forward ports 80 (HTTP) and 443 (HTTPS) to the master proxy server.

- HTTP (80) - routing by `$host`
- HTTPS (443) - routing by SNI (`ssl_preread`)
- SSL certificates are stored on backend servers
- Client access can be limited by IP

Detailed documentation and run instructions:
📄 [README.md](docs/en/README.ansible-master-proxy.md)

### Run
```bash
make master-proxy-setup
```


---

## Users Management

User management is handled via Ansible.

- Create system users
- Remove users from servers
- Manage sudo privileges
- SSH access via authorized keys
- Controlled via variables only (no code edits)

User actions are defined in a secrets file:
- `username` - user name
- `present_servers` - host groups where the user must exist
- `absent_servers` - host groups where the user must be removed

> ⚠️ Important  
> All playbooks are executed via Docker-based Ansible (`make` only).

Detailed documentation and usage:
📄 [README.md](docs/en/README.ansible-users-management.md)

### Run
```bash
make users-management
```

---

## SSH Security Hardening

Basic SSH security.

- SSH access restricted by IP whitelist
- Login notifications via Telegram
- Fail2Ban enabled (bruteforce protection)
- Optional Fail2Ban ban notifications
- SSH logging enabled

Security recommendations:
- Disable password login on critical servers
- Use SSH keys only
- Change default SSH port

> ⚠️ Important  
> SSH notifications about bans are disabled by default due to high bruteforce frequency.
> You'll just get tired of seeing these notifications after 3 minutes)

Detailed documentation and configuration:
📄 [README.md](docs/en/README.ansible-ssh-configuration.md)

### Run
```bash
make ssh-conf-setup
```
> ⚠️ IMPORTANT  
> Before running, make sure the Telegram bot token, chat ID, and topic ID are set in the files  
> ([ssh-notify.sh.example](src/ansible-ssh-configuration/ssh/ssh-notify.sh.example),  
> [ssh.conf.example](src/ansible-ssh-configuration/ssh/fail2ban/jail.d/ssh.conf.example))

---

## Nginx Setup

- Nginx Installation and Basic Configuration
- Install or upgrade Nginx to the specified version
- Unified baseline Nginx configuration across all servers
- Custom HTML error pages in corporate branding
- Main HTML landing page with a link to the primary website and a contact email
- Performance tuning and basic security hardening
- Extended log format for further analysis

Recommendations and Security:
- `server_tokens` off - hide the Nginx version
- Increased limits for file size and request body
- Optimized worker processes and network settings

>⚠️ Important
To enable custom error pages for services (domains), add the following directive:
`include snippets/custom_errors.conf`;

Detailed documentation and launch instructions:
📄 [README.md](docs/en/README.nginx-setup.md)

### Run
```bash
make nginx-setup
```
---


## NVIDIA GPU Driver Installation

Installs NVIDIA GPU drivers and configures Docker to work with GPUs via `nvidia-docker2`.
Ensures a consistent driver version and Docker configuration across all GPU-enabled servers.

1. Install the NVIDIA GPU driver
2. Install `nvidia-docker2` to enable GPU support in Docker

### Run
```bash
make gpu-setup
```

Detailed documentation and instructions:
📄 [README.md](docs/en/README.ansible-gpu-setup.md)

---

## GitLab Deployment

GitLab is deployed and maintained automatically.

- Deploy GitLab using Docker Compose
- Nginx reverse proxy with HTTPS
- GitLab backup creation
- Storing backups on the local machine from which the command is executed
- Restoring GitLab from a backup

> ⚠️ Important
> 
> All operations are performed via make and a Docker-based environment.
> Manual container management is not recommended.

Detailed documentation and instructions:
📄 [README.md](docs/en/README.ansible-gitlab.md)README.md

### Run (GitLab install / upgrade)
```bash
make gitlab-setup
```

### Run (Create backup GitLab)
```bash
make gitlab-backup-create
```

### Run (Restore backup GitLab)
```bash
make gitlab-backup-restore
```

> ⚠️ Attention
> 
> Before running the GitLab deployment, you must fill in the 
> environment variables and preinstall SSL certificates for 
> [Gitlab](../../src/ansible-gitlab/nginx/gitlab.example.com.conf.example), 
> [GitLab Pages](../../src/ansible-gitlab/nginx/pages.gitlab.example.com.conf.example), 
> and [GitLab Registry](../../src/ansible-gitlab/nginx/registry.gitlab.example.com.conf.example)
> on the server.
