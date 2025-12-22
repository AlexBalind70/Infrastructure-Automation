# Установка драйверов NVIDIA и Docker GPU

Данный модуль выполняет установку драйверов
NVIDIA и настройку Docker для работы с GPU. Обеспечивает
единый набор драйверов и конфигурацию Docker на всех GPU-серверах.

## Задачи

1. Добавление репозитория NVIDIA Container Toolkit
2. Обновление списка пакетов
3. Установка драйвера NVIDIA
4. Перезагрузка сервера
5. Установка nvidia-docker2
6. Копирование конфигурации Docker для GPU ([daemon.json](../../src/ansible-gpu-setup/nvidia-docker-conf/daemon.json))
7. Перезапуск Docker

## Docker daemon configuration ([daemon.json](../../src/ansible-gpu-setup/nvidia-docker-conf/daemon.json))

Основные параметры `daemon.json` описаны тут [README.ansible-docker-install.md](README.ansible-docker-install.md)

| Key           | Value                                         | Description                                                                                      |
|---------------|-----------------------------------------------|--------------------------------------------------------------------------------------------------|
| `runtimes`    | Объект с пользовательскими runtime-ами Docker | Позволяет задать альтернативные runtime для контейнеров.                                         |
| `nvidia`      | Имя runtime                                   | Определяет runtime с именем nvidia. Его можно использовать в контейнере через `--runtime=nvidia` |
| `path`        | `nvidia-container-runtime`                    | Указывает путь к бинарнику runtime, который будет запускать контейнеры с поддержкой GPU.         |

### Инструкция запуска

1. В файле `hosts` в группе `need_gpu_setup` записать целевые сервера
   на которых будет происходить установка драйверов
2. При надобности заменить версии драйвера Nvidia в [gpu-setup.yml](../../src/ansible-gpu-setup/playbooks/gpu-setup.yml)
   (по дефолту стоит nvidia-driver-535)
3. Запустить команду

```bash
make docker-setup
```
4. Проверить работу GPU на сервере:
```bash
nvidia-smi
```
5. Проверить работу GPU в Docker:
```bash
docker run --rm --gpus all nvidia/cuda:12.2.0-base nvidia-smi
```

## Рекомендации и проверка

- Убедитесь, что сервер оснащён совместимой NVIDIA GPU.
- Используйте данный плейбук как стандарт для всех
  GPU-серверов, чтобы поддерживать единый драйвер и конфигурацию Docker.

