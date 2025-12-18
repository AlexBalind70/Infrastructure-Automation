<p align="right">
  <a href="docs/ru/README.ru.md">RU</a> |
  <a href="README.md">EN</a>
</p>

# Infrastructure-Automation
The repository contains Ansible playbooks and auxiliary tools for automating server and infrastructure configuration


**Main tasks:**
  - Set up Master Proxy
  - Install Docker and Docker Compose


## Repository structure

```text
src/
├── ansible-docker-install/         # Docker installation and configuration
├── ansible-master-proxy            # Master proxy
├── keys                            # SSH keys for ansible
└── hosts.example
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
