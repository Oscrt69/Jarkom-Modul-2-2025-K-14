# Update config untuk redirect
cat > /etc/nginx/sites-available/default << 'EOF'
# Redirect sirion.k14.com dan IP ke www.k14.com
server {
    listen 80;
    server_name sirion.k14.com 10.15.43.37;
    return 301 http://www.k14.com$request_uri;
}

# Main server block
server {
    listen 80;
    server_name www.k14.com;
    
    location /admin {
        auth_basic "Admin Area";
        auth_basic_user_file /etc/nginx/.htpasswd;
        root /var/www;
        index index.html index.htm;
    }
    
    location /static/ {
        proxy_pass http://10.15.43.38/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        rewrite ^/static/(.*)$ /$1 break;
    }
    
    location /app/ {
        proxy_pass http://10.15.43.39/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        rewrite ^/app/(.*)$ /$1 break;
    }
    
    location / {
        root /var/www/html;
        index index.html index.htm;
    }
}
EOF

nginx -t && systemctl restart nginx
