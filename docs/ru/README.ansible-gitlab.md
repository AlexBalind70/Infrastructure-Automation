# GitLab Deployment

Данный модуль предназначен для развёртывания и обслуживания GitLab
в self-hosted окружении. GitLab запускается в Docker и доступен через Nginx
с полноценной HTTPS-конфигурацией.


## Что делает данный модуль

1. Развёртывание GitLab на сервере
2. Создание резервной копии (backup)
3. Восстановление GitLab из бэкапа

Все этапы автоматизированы и не требует ручного вмешательства.


## 1. Развёртывание GitLab

GitLab запускается через `docker-compose`.

Основные особенности:
- GitLab работает в контейнере
- Данные хранятся в volume
- Внешний доступ осуществляется через Nginx
- HTTPS настраивается через Certbot

### Конфигурация

Основные параметры задаются в [.env.example](../../src/ansible-gitlab/compose/.env.example) файле:

### Основные параметры GitLab
| Переменная             | Описание                                                                                                    |
| ---------------------- | ----------------------------------------------------------------------------------------------------------- |
| `GITLAB_EXTERNAL_URL`  | Внешний URL GitLab Web-интерфейса. Используется для генерации ссылок, OAuth, webhook’ов и email-уведомлений |
| `GITLAB_ROOT_PASSWORD` | Пароль пользователя `root`, устанавливается при первом запуске GitLab                                       |
| `GITLAB_SSH_PORT`      | Порт SSH для доступа к Git-репозиториям                                                                     |
| `GITLAB_PORT`          | Внутренний порт GitLab Web-сервиса, на который проксируется Nginx                                           |
| `GITLAB_POSTGRES_PORT` | Порт PostgreSQL, используемый GitLab                                                                        |
| `GITLAB_REDIS_PORT`    | Порт Redis, используемый GitLab                                                                             |

### SMTP (почта)
| Переменная        | Описание                                   |
| ----------------- | ------------------------------------------ |
| `SMTP_ADDRESS`    | SMTP-сервер для отправки email-уведомлений |
| `SMTP_PORT`       | Порт SMTP-сервера                          |
| `SMTP_USERNAME`   | Имя пользователя для аутентификации в SMTP |
| `SMTP_PASSWORD`   | Пароль для SMTP                            |
| `SMTP_DOMAIN`     | Домен, используемый в SMTP-заголовках      |
| `SMTP_FROM_EMAIL` | Email-адрес отправителя уведомлений GitLab |


### GitLab Container Registry
| Переменная              | Описание                                  |
| ----------------------- | ----------------------------------------- |
| `GITLAB_REGISTRY_PORT`  | Внутренний порт GitLab Container Registry |
| `REGISTRY_EXTERNAL_URL` | Внешний URL Docker Registry               |

#### Что такое GitLab Container Registry?

GitLab Container Registry - это встроенное Docker Registry.

Используется для:
- хранения Docker-образов
- публикации образов из CI/CD Gitlab
- централизованного хранения base-образов
- отказа от публичных registry (DockerHub)

Типовой сценарий: ``` CI → build image → push to GitLab Registry → deploy ```

### GitLab Pages

| Переменная                  | Описание                         |
| --------------------------- | -------------------------------- |
| `GITLAB_PAGES_EXTERNAL_URL` | Внешний URL сервиса GitLab Pages |

#### Что такое GitLab Pages

GitLab Pages - сервис для хостинга статических сайтов с помощью самого Gitlab.

Часто используется для:
- документации проектов
- лендингов
- статических сайтов
- превью результатов CI/CD

Особенности:

- сайты публикуются напрямую из репозиториев
- тесная интеграция с CI/CD Gitlab
- отдельный домен и виртуальный хост
- может работать параллельно с основным GitLab

Типовой сценарий: ``` Repo → CI → build static site → publish via GitLab Pages ```

GitLab Pages используется как отдельный virtual host и работает на выделенном домене.

Рекомендуется использовать подход wildcard DNS-запись, которая будет указывать, 
что все поддомены Pages обслуживаются одним сервером.

Это упрощает нам следующие вещи:
- управление DNS
- выпуск SSL-сертификатов
- сопровождение Gitlab Pages

#### Пример DNS-записи

Wildcard A-запись
```dns
*.pages.gitlab.example.com    A    <IP_ADDRESS_OF_PAGES_SERVER>
```

Wildcard A-запись делает Pages-проект автоматически доступным. Не требуется создавать DNS-запись для каждого проекта
GitLab сам формирует URL вида ` https://<project>.pages.gitlab.example.com `


#### SSL-сертификаты для GitLab Pages

Так как Pages используют динамические поддомены проектов, оптимальный вариант это
один wildcard SSL-сертификат, покрывающий все Pages-сайты. 

```
*.pages.gitlab.example.com
```

Этот сертификат будет действителен для всего Pages Gitlab.


#### Как выпустить wildcard-сертификат
Wildcard-сертификаты нельзя выпустить через HTTP-01 challenge.
Необходимо использовать DNS-01 challenge.

Инструкция:

1. Изменить запись в DNS для домена Pages Gitlab
2. Настроить Certbot с DNS-плагином
3. Выпустить сертификат:

```bash
certbot certonly \
  -d "*.pages.gitlab.example.com" \
  -d "pages.gitlab.example.com"
```
4. Указать сертификат в [Nginx-конфигурации Pages](../../src/ansible-gitlab/nginx/pages.gitlab.examplecom.conf)

>ℹ️ **Рекомендация**
> 
> Для GitLab Pages всегда используйте wildcard DNS + wildcard SSL.
> Любой другой подход плохо масштабируется и усложняет поддержку.


### Инструкция запуска

1. В файле `hosts` в группе `gitlab_setup` указать целевой сервер,
   на котором будет выполняться установка GitLab
2. Заполнить файл  
   [.env.example](../../src/ansible-gitlab/compose/.env.example)
3. Подготовить конфигурации Nginx для доменов:
   - [gitlab.example.com.conf](../../src/ansible-gitlab/nginx/gitlab.example.com.conf.example)
   - [pages.gitlab.example.com.conf](../../src/ansible-gitlab/nginx/pages.gitlab.example.com.conf.example)
   - [registry.gitlab.example.com.conf](../../src/ansible-gitlab/nginx/registry.gitlab.example.com.conf.example)
5. Запустить команду:

```bash
make gitlab-setup
```

> ⚠️ Внимание  
> Перед запуском деплоя GitLab необходимо заполнить [переменные окружения](../../src/ansible-gitlab/compose/.env.example)
> и заранее установить SSL-сертификаты для [Gitlab](../../src/ansible-gitlab/nginx/gitlab.example.com.conf.example), 
> [GitLab Pages](../../src/ansible-gitlab/nginx/pages.gitlab.example.com.conf.example) и 
> [GitLab Registry](../../src/ansible-gitlab/nginx/registry.gitlab.example.com.conf.example) на сервере.


## 2. Создание резервной копии Gitlab

GitLab поддерживает встроенный механизм резервного копирования.

В рамках данного модуля создаётся backup внутри контейнера GitLab, далее архив автоматически копируется
и сохраняется **на локальной машине**, с которой выполняется запуск.

Бэкапы сохраняются в каталог ` ./backups/gitlab/ `

Бэкап не остаётся на сервере (он сразу удаляется, после передачи на локальную машину) 
это снижает риск потери данных при компрометации или сбое сервера. Да и так просто удобнее.

Бэкап включает в себя:
- репозитории
- базу данных
- загрузки
- конфигурацию GitLab

### Инструкция запуска

1. В файле `hosts` в группе `gitlab_backup_create` указать целевой сервер,
   на котором будет создаваться BackUp GitLab
2. Запустить команду:

```bash
make gitlab-backup-create
```


## 3. Восстановление из бэкапа

Для восстановаления бэкапа, в папку  [backup](../../src/ansible-gitlab/backup)
пололожить свежий бэкап Gitlab, который собираетесь распаковать.

Процесс восстановления:

1. GitLab останавливается
2. Бэкап загружается в контейнер
3. Выполняется восстановление данных
4. GitLab запускается обратно

Восстановление полностью автоматизировано
и не требует ручного вмешательства в контейнер.

### Инструкция запуска

1. В файле `hosts` в группе `gitlab_backup_restore` указать целевой сервер,
   на котором будет восстановаливаться BackUp GitLab
2. В папку [backup](../../src/ansible-gitlab/backup) положить Backup, который будете восстанавливать
3. Запустить команду:

```bash
make gitlab-backup-restore
```

---

## Логирование

- GitLab логи сохраняются внутри контейнера
- Nginx ведёт отдельные access и error логи
- Используются расширенные форматы логов
- Логи пригодны для последующего экспорта и анализа

---

## Почему Gitlab в Docker

- GitLab изолирован от системы
- Простое обновление и миграция
- Быстрое восстановление из бэкапа
- Минимум ручных действий
- Предсказуемая конфигурация

---





