#!/bin/bash

server {
    listen 80;
    server_name sirion.k14.com www.k14.com;

    if ($host = sirion.k14.com) {
        return 301 http://www.k14.com$request_uri;
    }

    location /static/ {
        proxy_pass http://10.15.43.38/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /app/ {
        proxy_pass http://10.15.43.39/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        rewrite ^/app/about(/.*)?$ /about$1 break;
    }

    location /admin {
        auth_basic "Administrator Area";
        auth_basic_user_file /etc/nginx/.htpasswd;
        proxy_pass http://10.15.43.39/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location / {
        return 200 '<!DOCTYPE html>
        <html>
        <head>
            <title>War of Wrath: Lindon Bertahan</title>
        </head>
        <body>
            <h1>War of Wrath: Lindon Bertahan</h1>
            <p><a href="/static">Menuju Arsip Statis Lindon</a></p>
            <p><a href="/app">Menuju Aplikasi Dinamis Vingilot</a></p>
        </body>
        </html>';
        add_header Content-Type text/html;
    }
}
EOF

# Restart nginx
systemctl restart nginx
systemctl enable nginx

echo "Reverse proxy Sirion berhasil dikonfigurasi"
