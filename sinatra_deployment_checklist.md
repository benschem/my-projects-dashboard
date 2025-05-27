# Sinatra App Production Deployment Checklist

This checklist assumes deployment to a Fedora Linux VM using Puma as the app server and NGINX as a reverse proxy. The app is deployed to `/var/www/my_sinatra_app`.

## Upload App to Server

[ ] Create the app directory on the server:
`mkdir -p /var/www/my_sinatra_app`
[ ] Upload files via rsync, Git, or SCP:

    ```bash
    ssh user@ip
    cd /var/www/
    git clone https://github.com/benschem/my-projects-dashboard.git my-projects-dashboard
    ```

## Install Ruby and Dependencies

[ ] SSH into the server
[ ] Install Ruby via `rbenv`
[ ] Install dependencies:

    ```bash
    sudo dnf update
    sudo dnf groupinstall "Development Tools"
    sudo dnf install gcc-c++ make
    ```

[ ] Install Bundler:

    ```bash
    gem install bundler
    ```

[ ] Run:

    ```bash
    cd /var/www/my-projects-dashboard
    bundle install --deployment --without development test
    ```

## Create Required Directories

[ ] Ensure the following directories exist and are writable by the app:

    ```bash
    mkdir -p tmp/pids
    mkdir -p log
    mkdir -p data
    ```

## Add Configuration Files

[ ] Ensure a `config.ru` file exists with:

    ```ruby
    require './app'
    run MyProjectsDashboard
    ```

[ ] Create a `config/puma.rb` file:

    ```ruby
    workers 2
    threads 1, 6

    environment ENV.fetch("RACK_ENV") { "production" }

    port ENV.fetch("PORT") { 9292 }
    pidfile "tmp/pids/puma.pid"

    stdout_redirect "log/stdout", "log/stderr", true
    ```

## Set Environment Variables

[ ] Create `/etc/my-projects-dashboard.env`:

    ```
    RACK_ENV=production
    GITHUB_ACCESS_TOKEN=your_token
    REPOS_FILE=/var/www/my-projects-dashboard/data/repos.json
    ```

[ ] Secure this file:

    ```bash
    sudo chmod 640 /etc/my-projects-dashboard.env
    sudo chown root:www-data /etc/my-projects-dashboard.env
    ```

## Create systemd Service File

[ ] Create `/etc/systemd/system/my-projects-dashboard.service`:

    ```
    [Unit]
    Description=My Sinatra App
    After=network.target

    [Service]
    User=www-data
    WorkingDirectory=/var/www/my-projects-dashboard
    ExecStart=/usr/bin/env bundle exec puma -C config/puma.rb
    Restart=on-failure
    EnvironmentFile=/etc/my-projects-dashboard.env

    [Install]
    WantedBy=multi-user.target
    ```

[ ] Reload systemd and start service:

    ```bash
    sudo systemctl daemon-reload
    sudo systemctl enable my-projects-dashboard
    sudo systemctl start my-projects-dashboard
    ```

## Configure NGINX

[ ] Create `/etc/nginx/sites-available/my-projects-dashboard`:

    ```
    server {
        listen 80;
        server_name yourdomain.com;

        root /var/www/my-projects-dashboard/public;

        location / {
            proxy_pass http://localhost:9292;
            proxy_http_version 1.1;
            proxy_set_header Connection '';
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
            expires max;
            add_header Cache-Control public;
        }
    }
    ```

[ ] Enable site and reload NGINX:

    ```bash
    sudo ln -s /etc/nginx/sites-available/my-projects-dashboard /etc/nginx/sites-enabled/
    sudo nginx -t
    sudo systemctl reload nginx
    ```

## Test Deployment

[ ] Visit `http://yourdomain.com`
[ ] Check logs:

    ```bash
    sudo systemctl status my-projects-dashboard
    sudo journalctl -u my-projects-dashboard -f
    ```

## Set Permissions

[ ] Ensure app files are readable by `www-data`
[ ] Ensure `data/repos.json` is writable by app user
[ ] `sudo chown -R www-data:www-data /var/www/my-projects-dashboard`

## Push-to-Deploy Setup

### On server:

[ ] Create bare repo:

    ```bash
    mkdir -p /var/repo/my-projects-dashboard.git
    cd /var/repo/my-projects-dashboard.git
    git init --bare
    ```

[ ] Add `hooks/post-receive`:

    ```
    #!/bin/bash
    GIT_WORK_TREE=/var/www/my-projects-dashboard git checkout -f
    cd /var/www/my-projects-dashboard
    bundle install --deployment --without development test
    sudo systemctl restart my-projects-dashboard
    ```

[ ] Make executable:

    ```bash
    chmod +x hooks/post-receive
    ```

### On local machine:

[ ] Add remote:

    ```bash
    git remote add production youruser@yourdomain.com:/var/repo/my-projects-dashboard.git
    git push production main
    ```
