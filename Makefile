DOCKER_COMPOSE_RUN=docker compose run --rm ansible
ANSIBLE=$(DOCKER_COMPOSE_RUN) ansible
ANSIBLE_PLAYBOOK=$(DOCKER_COMPOSE_RUN) ansible-playbook

setup-project:
	bash setup-project.sh

build:
	docker compose build --progress plain

docker-setup: build
	$(ANSIBLE_PLAYBOOK) ansible-docker-install/playbooks/docker-install.yml

master-proxy-setup: build
	$(ANSIBLE_PLAYBOOK) ansible-master-proxy/playbooks/master_proxy.yml

