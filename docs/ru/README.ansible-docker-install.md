# Docker Install
Установка и базовая настройка Docker.

## Ansible variables (Docker)
Ниже приведены переменные Ansible, используемые для установки и настройки Docker.

| Variable                   | Description                                               |
| -------------------------- | --------------------------------------------------------- |
| `docker_version`           | Версия Docker Engine, которая будет установлена на сервер |
| `docker_compose_version`   | Версия Docker Compose (v2), устанавливаемая на сервер     |
| `src_docker_configuration` | Путь к файлу конфигурации Docker daemon (`daemon.json`)   |


### Пример
```
docker_version: "5:28.0.4-1~ubuntu.24.04~noble"
docker_compose_version: "2.27.0"
src_docker_configuration: "{{ playbook_dir }}/../configuration/daemon.json"
```


## Docker daemon configuration (daemon.json)

Docker daemon настраивается с помощью файла daemon.json,
который копируется на сервер в `/etc/docker/daemon.json`.

### Общие параметры

| Key                 | Value       | Description                                                         |
| ------------------- |-------------|---------------------------------------------------------------------|
| `log-driver`        | `json-file` | стандартный драйвер логов Docker (логи пишутся в файлы на диске)    |
| `live-restore`      | `true`      | контейнеры продолжают работать при перезапуске Docker daemon        |
| `storage-driver`    | `overlay2`  | рекомендуемый драйвер хранения для Linux                            |
| `features.buildkit` | `true`      | включает BuildKit для ускоренной и более эффективной сборки образов |
| `log-opts.max-size` | `10m`       | Максимальный размер одного файла логов контейнера                   |
| `log-opts.max-file` | `3`         | Максимальное количество файлов логов на контейнер                   |

> Для конфигурации `daemon.json` обращаться нужно к  [документации Docker](https://docs.docker.com)

## Управление и развёртывание
Установка и настройка Docker выполняется с помощью Ansible

### Инструкция запуска
1. В файле `hosts` в группе `docker_install` записать целевые сервера 
на которых будет происходить установка
2. При надобности заменить версии Docker и Docker Compose в [docker-install.yml](../../src/ansible-docker-install/playbooks/docker-install.yml)
3. Запустить команду 
```bash
make docker-setup
```

## Рекомендации

- Не изменять daemon.json вручную на сервере
- Все изменения должны вноситься через Ansible для лучшего контроля
- Версии Docker и Compose должны быть одинаковыми во всех окружениях (dev/staging/prod) 
 во избежания конфуза при деплоях в разные окружения