# GitLab Deployment

This module is designed for deploying and maintaining GitLab in a self-hosted environment.
GitLab runs in Docker and is exposed via Nginx with a full HTTPS configuration.


## What this module does

1. Deploys GitLab on a server
2. Creates backups
3. Restores GitLab from backups

All steps are fully automated and require no manual intervention.


## 1. GitLab Deployment

GitLab is started using `docker-compose`.

Key characteristics:
- GitLab runs inside a container
- Data is stored in volumes
- External access is provided via Nginx
- HTTPS is configured using Certbot

### Configuration

The main parameters are defined in the [.env.example](../../src/ansible-gitlab/compose/.env.example) file:

### Core GitLab parameters
| Variable               | Description                                                                                                |
| ---------------------- | ---------------------------------------------------------------------------------------------------------- |
| `GITLAB_EXTERNAL_URL`  | Public URL of the GitLab web interface. Used for link generation, OAuth, webhooks, and email notifications |
| `GITLAB_ROOT_PASSWORD` | Password for the `root` user, set during the first GitLab startup                                          |
| `GITLAB_SSH_PORT`      | SSH port used to access Git repositories                                                                   |
| `GITLAB_PORT`          | Internal GitLab web service port proxied by Nginx                                                          |
| `GITLAB_POSTGRES_PORT` | PostgreSQL port used by GitLab                                                                             |
| `GITLAB_REDIS_PORT`    | Redis port used by GitLab                                                                                  |


### SMTP (email)
| Variable          | Description                                   |
| ----------------- | --------------------------------------------- |
| `SMTP_ADDRESS`    | SMTP server used to send email notifications  |
| `SMTP_PORT`       | SMTP server port                              |
| `SMTP_USERNAME`   | SMTP authentication username                  |
| `SMTP_PASSWORD`   | SMTP authentication password                  |
| `SMTP_DOMAIN`     | Domain used in SMTP headers                   |
| `SMTP_FROM_EMAIL` | Sender email address for GitLab notifications |


### GitLab Container Registry
| Variable                | Description                                |
| ----------------------- | ------------------------------------------ |
| `GITLAB_REGISTRY_PORT`  | Internal port of GitLab Container Registry |
| `REGISTRY_EXTERNAL_URL` | Public URL of the Docker Registry          |


#### What is GitLab Container Registry?

GitLab Container Registry is a built-in Docker registry.

It is used for:
- storing Docker images
- publishing images from GitLab CI/CD
- centralized storage of base images
- eliminating dependency on public registries (e.g. DockerHub)

Typical workflow: ``` CI → build image → push to GitLab Registry → deploy ```

### GitLab Pages

| Variable                    | Description                            |
| --------------------------- | -------------------------------------- |
| `GITLAB_PAGES_EXTERNAL_URL` | Public URL of the GitLab Pages service |


#### What is GitLab Pages?

GitLab Pages is a service for hosting static websites directly from GitLab.

Common use cases:
- project documentation
- landing pages
- static websites
- CI/CD preview environments

Key features Gitlab Pages:

- sites are published directly from repositories
- tight integration with GitLab CI/CD
- separate domain and virtual host
- can run in parallel with the main GitLab instance

Typical workflow: ``` Repo → CI → build static site → publish via GitLab Pages ```

GitLab Pages runs as a separate virtual host and is served on a dedicated domain.

It is recommended to use a wildcard DNS record pointing all Pages subdomains to a single server.

This significantly simplifies:
- DNS management
- SSL certificate issuance
- GitLab Pages maintenance

#### DNS record example

Wildcard A record:
```dns
*.pages.gitlab.example.com    A    <IP_ADDRESS_OF_PAGES_SERVER>
```

A wildcard A record makes all Pages projects automatically accessible without creating a DNS record per project.
GitLab generates URLs in the following format: ` https://<project>.pages.gitlab.example.com `


#### SSL certificates for GitLab Pages

Since Pages use dynamic project subdomains, 
the optimal approach is a single wildcard SSL certificate covering all Pages sites:

```
*.pages.gitlab.example.com
```

This certificate will be valid for all GitLab Pages projects.

#### How to issue a wildcard certificate
Wildcard certificates cannot be issued using the HTTP-01 challenge.
You must use the DNS-01 challenge.

Steps:

1. Update DNS records for the GitLab Pages domain
2. Configure Certbot with a DNS plugin
3. Issue the certificate:

```bash
certbot certonly \
  -d "*.pages.gitlab.example.com" \
  -d "pages.gitlab.example.com"
```
4. Reference the certificate in the [Nginx Pages configuration](../../src/ansible-gitlab/nginx/pages.gitlab.examplecom.conf)

>ℹ️ **Recommendation**
> 
> Always use wildcard DNS and wildcard SSL certificates for GitLab Pages.
> Any other approach does not scale well and significantly complicates maintenance.


### Deployment instructions

1. In the `hosts` file, add the target server to the `gitlab_setup` group
2. Fill in the  
   [.env.example](../../src/ansible-gitlab/compose/.env.example)
3. Prepare Nginx configurations for the domains:
   - [gitlab.example.com.conf](../../src/ansible-gitlab/nginx/gitlab.example.com.conf.example)
   - [pages.gitlab.example.com.conf](../../src/ansible-gitlab/nginx/pages.gitlab.example.com.conf.example)
   - [registry.gitlab.example.com.conf](../../src/ansible-gitlab/nginx/registry.gitlab.example.com.conf.example)
5. Run:

```bash
make gitlab-setup
```

> ⚠️ Attention
> 
> Before running the GitLab deployment, you must fill in the 
> environment variables and preinstall SSL certificates for 
> [Gitlab](../../src/ansible-gitlab/nginx/gitlab.example.com.conf.example), 
> [GitLab Pages](../../src/ansible-gitlab/nginx/pages.gitlab.example.com.conf.example), 
> and [GitLab Registry](../../src/ansible-gitlab/nginx/registry.gitlab.example.com.conf.example)
> on the server.


## 2. GitLab Backup Creation

GitLab provides a built-in backup mechanism.

Within this module, a backup is created inside the GitLab container and then automatically 
copied and stored on the **local machine** from which the command is executed.

Backups are stored in: ` ./backups/ `

The backup does not remain on the server (it is immediately deleted after being transferred to the local machine) 
this reduces the risk of data loss if the server is compromised or crashed. And it's just more convenient that way.

The backup includes:
- Repositories
- Database
- Uploads
- GitLab configuration

### Run instructions

1. In the `hosts` file, add the target server to the `gitlab_backup_create` group
2. Run:

```bash
make gitlab-backup-create
```


## 3. Restoring from a Backup

To restore a backup, place the desired GitLab backup archive into the  [backup](../../src/ansible-gitlab/backup) directory.

Restore process:

1. GitLab is stopped
2. The backup is uploaded into the container
3. Data restoration is performed
4. GitLab is started again

The restore process is fully automated and does not require manual interaction with the container.

### Run instructions

1. In the`hosts` file, add the target server to the `gitlab_backup_restore` group
2. Place the backup archive into [backup](../../src/ansible-gitlab/backup) 
3. Run:

```bash
make gitlab-backup-restore
```

---

## Logging

- GitLab logs are stored inside the container
- Nginx maintains separate access and error logs
- Extended log formats are used
- Logs are suitable for further export and analysis

---

## Why GitLab runs in Docker

- GitLab is isolated from the host system
- Easy upgrades and migrations
- Fast recovery from backups
- Minimal manual operations
- Predictable and reproducible configuration

---





