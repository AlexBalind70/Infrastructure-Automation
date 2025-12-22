# Nginx Setup

Данный модуль выполняет установку и базовую настройку Nginx
с единой конфигурацией для всех серверов.

Основные цели:
- унификация конфигурации Nginx
- упрощение обновлений и поддержки
- базовое усиление безопасности
- единое логирование
- корректное взаимодействие с внешними пользователями

---

## Установка и обновление

Nginx устанавливается или обновляется автоматически.

Необходимая версия указывается в переменной:

| Переменная | Описание |
|----------|----------|
| `nginx_version` | Версия Nginx, которая должна быть установлена |

Это позволяет нам:
- контролировать обновления
- поддерживать одинаковую версию Nginx на всех серверах
- избегать неожиданных изменений поведения

---

## Назначение

Замена стандартных страниц ошибок Nginx и отображение главной страницы с ссылкой на основной 
сайт компании, и контактной почтой для обратной связи.

**Для чего это сделанно?:**
- пользователям, попавшим на сервер по IP, показывается корректное направление
- специалисты по безопасности могут связаться с компанией при обнаружении уязвимостей


---

## Подключение кастомных ошибок

Для использования кастомных страниц в конфигурациях сервисов необходимо добавить:

```nginx
include snippets/custom_errors.conf;
```
Это позволяет централизованно использовать единый набор страниц ошибок в Nginx.

**Пример главной страницы Nginx:**
![img.png](../static/index_html_default.png)

**Пример страницы ошибки (500 code error)**
![img.png](../static/error_500_nginx_page.png)
---

---

## Базовая конфигурация Nginx

Применяется минимальная, но готовая к production конфигурация Nginx.

Она включает:

- оптимизацию производительности
- базовые меры безопасности
- глобальные лимиты
- единый формат логирования

---

## Основные параметры конфигурации

### Общие и производительность

| Параметр             | Назначение                          |
| -------------------- | ----------------------------------- |
| `worker_processes`   | Автоматически по количеству CPU     |
| `worker_connections` | Повышенное количество соединений    |
| `sendfile`           | Ускорение отдачи статических файлов |
| `tcp_nopush`         | Оптимизация отправки пакетов        |
| `tcp_nodelay`        | Улучшение работы keep-alive         |


### Лимиты и буферы

| Параметр                      | Назначение                                 |
| ----------------------------- |--------------------------------------------|
| `client_max_body_size`        | Увеличенный размер загружаемых файлов (100 |
| `client_body_buffer_size`     | Буфер тела запроса                         |
| `large_client_header_buffers` | Поддержка больших заголовков               |


### Безопасность

| Параметр            | Назначение                             |
| ------------------- | -------------------------------------- |
| `server_tokens off` | Скрытие версии Nginx в HTTP-заголовках |
| `ssl_protocols`     | Использование безопасных версий TLS    |

> Это базовые требования безопасности.


### Логирование

Определены два формата логов:

| Формат     | Назначение                             |
| ---------- | -------------------------------------- |
| `main`     | Базовое логирование запросов           |
| `detailed` | Расширенные логи с таймингами upstream |

Для применения формата логов для доменов в блоке `server`  писать так 

```commandline
access_log /var/log/nginx/example.com_access.log detailed;
error_log /var/log/nginx/example.com.com_error.log warn;
```

Это позволяет:

- анализировать производительность
- искать проблемы с задержками
- в дальнейшем подключать системы мониторинга и экспорта логов

### Сжатие

| Параметр          | Назначение                         |
| ----------------- | ---------------------------------- |
| `gzip on`         | Включение gzip-сжатия              |
| `gzip_types`      | Оптимизированный список MIME-типов |
| `gzip_comp_level` | Баланс нагрузки и сжатия           |

### Инструкция запуска
1. В файле `hosts` в группе `nginx_setup` записать целевые сервера 
на которых будет происходить установка
2. При надобности заменить версии Nginx в [nginx_custom.yml](../../src/ansible-nginx-configuration/playbooks/nginx_custom.yml)
3. Запустить команду

```bash
make nginx-setup
```


**Пример конфига для `example.com`**

```nginx
upstream example_host_service {
    server 127.0.0.1:1111;
}

server {
    server_name example.com;
    
    # Include custom errors
    include snippets/custom_errors.conf;
    
    #Settings for Logs
    access_log /var/log/nginx/example.com_access.log detailed;
    error_log /var/log/nginx/example.com_error.log warn;

    # Main location
    location / {
        proxy_pass https://example_host_service;
    }

     listen 443 ssl; # managed by Certbot
     ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem; # managed by Certbot
     ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem; # managed by Certbot
     include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
     ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

}

server {
     if ($host = example.com) {
         return 301 https://$host$request_uri;
     } # managed by Certbot

    access_log /var/log/nginx/example.com_http_access.log main;
    error_log /var/log/nginx/example.com_http_error.log warn;

    server_name example.com;
    listen 80;
    
    return 404; # managed by Certbot
}
```





