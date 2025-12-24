DOCKER_COMPOSE_RUN=docker compose run --rm ansible
ANSIBLE=$(DOCKER_COMPOSE_RUN) ansible
ANSIBLE_PLAYBOOK=$(DOCKER_COMPOSE_RUN) ansible-playbook

ifeq ($(OS),Windows_NT)
SETUP_CMD = powershell -ExecutionPolicy Bypass -File scripts\setup-project.ps1
else
SETUP_CMD = bash scripts/setup-project.sh
endif

.PHONY: setup-project build docker-setup master-proxy-setup

setup-project:
	$(SETUP_CMD)

build:
	docker compose build --progress plain

docker-setup: build
	$(ANSIBLE_PLAYBOOK) ansible-docker-install/playbooks/docker-install.yml

master-proxy-setup: build
	$(ANSIBLE_PLAYBOOK) ansible-master-proxy/playbooks/master_proxy.yml

users-management: build
	$(ANSIBLE_PLAYBOOK) ansible-users-management/playbooks/users_management.yml

ssh-conf-setup: build
	$(ANSIBLE_PLAYBOOK) ansible-ssh-configuration/playbooks/ssh_configuration.yml

nginx-setup: build
	$(ANSIBLE_PLAYBOOK) ansible-nginx-setup/playbooks/nginx-setup.yml

gpu-setup: build
	$(ANSIBLE_PLAYBOOK) ansible-gpu-setup/playbooks/gpu-setup.yml

gitlab-setup: build
	$(ANSIBLE_PLAYBOOK) ansible-gitlab/playbooks/gitlab-deploy.yml

gitlab-backup-create: build
	$(ANSIBLE_PLAYBOOK) ansible-gitlab/playbooks/gitlab-backup-create.yml

gitlab-backup-restore: build
	$(ANSIBLE_PLAYBOOK) ansible-gitlab/playbooks/gitlab-backup-restore.yml
