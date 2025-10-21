# Install tools
apt install -y apache2-utils

# Buat directory admin
mkdir -p /var/www/admin
cat > /var/www/admin/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Admin Area</title>
</head>
<body>
    <h1>Admin Panel k14.com</h1>
    <p>Protected by Basic Authentication</p>
</body>
</html>
EOF

# Buat user/password
htpasswd -bc /etc/nginx/.htpasswd admin admin123

# Update config nginx
cat > /etc/nginx/sites-available/default << 'EOF'
server {
    listen 80;
    server_name sirion.k14.com www.k14.com;
    
    # Basic Auth untuk /admin
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
