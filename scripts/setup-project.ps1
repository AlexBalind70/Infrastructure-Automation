Write-Host "exporting variables from .env.example"

Get-Content .env.example | ForEach-Object {
    if ($_ -match '^\s*#') { return }
    if ($_ -match '^\s*$') { return }

    $pair = $_ -split '=', 2
    $name = $pair[0].Trim()
    $value = $pair[1].Trim('"')

    [System.Environment]::SetEnvironmentVariable($name, $value)
}

Write-Host "writing SSH keys..."
New-Item -ItemType Directory -Force -Path .\src\keys | Out-Null

$env:ANSIBLE_SSH_PRIVATE_KEY | Out-File -Encoding ascii .\src\keys\ssh-private-key
$env:ANSIBLE_SSH_PUBLIC_KEY  | Out-File -Encoding ascii .\src\keys\ssh-public-key

Copy-Item src\hosts.example src\hosts -Force

# For Nginx
Copy-Item src\ansible-master-proxy\nginx\conf.d\master-proxy.conf.example src\ansible-master-proxy\nginx\conf.d\master-proxy.conf -Force
Copy-Item src\ansible-master-proxy\nginx\stream.d\base-stream.conf.example src\ansible-master-proxy\nginx\stream.d\base-stream.conf -Force
Copy-Item src\ansible-master-proxy\nginx\nginx.conf.example src\ansible-master-proxy\nginx\nginx.conf -Force


# For SSH Configuration
Copy-Item src\ansible-ssh-configuration\ssh\fail2ban\jail.d\ssh.conf.example src\ansible-ssh-configuration\ssh\fail2ban\jail.d\ssh.conf -Force
Copy-Item src\ansible-ssh-configuration\ssh\fail2ban\telegram-ban.conf.example src\ansible-ssh-configuration\ssh\fail2ban\telegram-ban.conf -Force
Copy-Item src\ansible-ssh-configuration\ssh\ssh-notify.sh.example src\ansible-ssh-configuration\ssh\ssh-notify.sh -Force
Copy-Item src\ansible-ssh-configuration\ssh\sshd_config.example src\ansible-ssh-configuration\ssh\sshd_config -Force


# Fot Gitlab deploy
Copy-Item src/ansible-gitlab/compose/.env.example src/ansible-gitlab/compose/.env -Force
Copy-Item src/ansible-gitlab/nginx/gitlab.example.com.conf.example src/ansible-gitlab/nginx/gitlab.example.com.conf -Force
Copy-Item src/ansible-gitlab/nginx/pages.gitlab.example.com.conf.example src/ansible-gitlab/nginx/pages.gitlab.example.com.conf -Force
Copy-Item src/ansible-gitlab/nginx/registry.gitlab.example.com.conf.example src/ansible-gitlab/nginx/registry.gitlab.example.com.conf -Force


