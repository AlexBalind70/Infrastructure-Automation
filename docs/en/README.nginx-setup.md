# Nginx Setup

This module installs and performs the basic configuration of Nginx
using a unified configuration across all servers.

Primary goals:
- Nginx configuration standardization
- Easier updates and maintenance
- Basic security hardening
- Unified logging
- Proper interaction with external users

---

## Installation and Upgrade

Nginx is installed or upgraded automatically.

The required version is defined via the variable:

| Variable        | Description                              |
| --------------- | ---------------------------------------- |
| `nginx_version` | The Nginx version that must be installed |

This allows us to:
- Control upgrades
- Maintain the same Nginx version on all servers
- Avoid unexpected behavior changes

---

## Purpose


Replace the default Nginx error pages and display a landing page with a link to the company’s main website and a contact email for feedback.

**Why this is needed:**
- Users accessing the server directly by IP are guided correctly
- Security researchers can easily contact the company 
when vulnerabilities are discovered

---

## Enabling Custom Error Pages

To use custom error pages in service configurations, add:

```
include snippets/custom_errors.conf;
```

This enables centralized reuse of a single set of error pages across Nginx.

**Example main page:**
![img.png](../static/index_html_default.png)

**Example Nginx page error (500 code error)**

![img.png](../static/error_500_nginx_page.png)
---


## Base Nginx Configuration

A minimal but production-ready Nginx configuration is applied.

It includes:
- Performance optimizations
- Basic security measures
- Global limits
- A unified logging format

## Key Configuration Parameters

### General and Performance
| Parameter            | Purpose                                    |
| -------------------- | ------------------------------------------ |
| `worker_processes`   | Automatically set based on CPU count       |
| `worker_connections` | Increased number of concurrent connections |
| `sendfile`           | Faster static file delivery                |
| `tcp_nopush`         | Optimized packet transmission              |
| `tcp_nodelay`        | Improved keep-alive behavior               |

### Limits and Buffers
| Parameter                     | Purpose                              |
| ----------------------------- | ------------------------------------ |
| `client_max_body_size`        | Increased upload size limit (100 MB) |
| `client_body_buffer_size`     | Request body buffer size             |
| `large_client_header_buffers` | Support for large request headers    |


### Security
| Parameter           | Purpose                                |
| ------------------- | -------------------------------------- |
| `server_tokens off` | Hide the Nginx version in HTTP headers |
| `ssl_protocols`     | Enforce secure TLS versions            |
> These are baseline security requirements.


### Logging

Two log formats are defined:

| Format     | Purpose                                    |
| ---------- | ------------------------------------------ |
| `main`     | Basic request logging                      |
| `detailed` | Extended logs with upstream timing details |

To apply a log format for a domain, configure it in the `server` block as follows:

```commandline
access_log /var/log/nginx/example.com_access.log detailed;
error_log  /var/log/nginx/example.com_error.log warn;
```

This allows you to:
- Analyze performance
- Identify latency issues
- Integrate monitoring and log export systems later


## Compression

| Parameter         | Purpose                            |
| ----------------- | ---------------------------------- |
| `gzip on`         | Enable gzip compression            |
| `gzip_types`      | Optimized list of MIME types       |
| `gzip_comp_level` | Balance between CPU load and ratio |

## Run Instructions
1. In the [hosts](../../src/hosts.example) file, add target servers to the nginx_setup group
where the installation will be performed
2. If needed, change the Nginx version in
[nginx-setup.yml](../../src/ansible-nginx-setup/playbooks/nginx-setup.yml)
3. Run the command:

```bash
make nginx-setup
```

**Example configuration for `example.com`**

```nginx
upstream example_host_service {
    server 127.0.0.1:1111;
}

server {
    server_name example.com;
    
    # Include custom errors
    include snippets/custom_errors.conf;
    
    # Settings for Logs
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




