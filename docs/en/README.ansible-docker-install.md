# Docker Install
Docker installation and basic setup.

## Ansible variables (Docker)
Below are the Ansible variables used to install and configure Docker.

| Variable                   | Description                                                  |
| -------------------------- |--------------------------------------------------------------|
| `docker_version`           | Docker Engine version to be installed on the server          |
| `docker_compose_version`   | Docker Compose (v2) version to be installed on the server    |
| `src_docker_configuration` | Path to the Docker daemon configuration file (`daemon.json`) |


### Example
```
docker_version: "5:28.0.4-1~ubuntu.24.04~noble"
docker_compose_version: "2.27.0"
src_docker_configuration: "{{ playbook_dir }}/../configuration/daemon.json"
```


## Docker daemon configuration (daemon.json)

Docker daemon is configured using the [daemon.json](../../src/ansible-docker-install/configuration/daemon.json) file.
It is copied to the server at `/etc/docker/daemon.json`.

### Common settings

| Key                 | Value       | Description                                                         |
| ------------------- |-------------|---------------------------------------------------------------------|
| `log-driver`        | `json-file` | Default Docker log driver (logs are written to files on disk)    |
| `live-restore`      | `true`      | Containers keep running when the Docker daemon restarts        |
| `storage-driver`    | `overlay2`  | Recommended storage driver for Linux                         |
| `features.buildkit` | `true`      | Enables BuildKit for faster and more efficient image builds |
| `log-opts.max-size` | `10m`       | Maximum size of a single container log file                  |
| `log-opts.max-file` | `3`         | Maximum number of log files per container                   |

> For`daemon.json` configuration, refer to the  [Docker documentation](https://docs.docker.com)

## Management and deployment
Docker installation and configuration are handled via Ansible.

### How to run
1. In the `hosts` file, add the target servers to the `docker_install` group
where Docker will be installed
2. If needed, change Docker and Docker Compose versions in [docker-install.yml](../../src/ansible-docker-install/playbooks/docker-install.yml)
3. Run:
```bash
make docker-setup
```


## Recommendations

- Do not edit `daemon.json` manually on the server
- All changes should go through Ansible for proper control
- Docker and Compose versions should be the same across all environments
(dev / staging / prod) to avoid deployment issues