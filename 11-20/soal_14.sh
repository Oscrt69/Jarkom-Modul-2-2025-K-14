# Install nginx & PHP
apt update && apt install -y nginx php8.4-fpm

# Buat web application
mkdir -p /var/www/html
cat > /var/www/html/index.php << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Vingilot App</title>
</head>
<body>
    <h1>Vingilot Dynamic Application</h1>
    <p><strong>Client IP:</strong> <?php echo $_SERVER['REMOTE_ADDR']; ?></p>
    <p><strong>X-Real-IP:</strong> <?php echo $_SERVER['HTTP_X_REAL_IP'] ?? 'Not set'; ?></p>
    <p><strong>X-Forwarded-For:</strong> <?php echo $_SERVER['HTTP_X_FORWARDED_FOR'] ?? 'Not set'; ?></p>
    <a href="/about">About Page</a>
</body>
</html>
EOF

cat > /var/www/html/about.php << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>About - Vingilot</title>
</head>
<body>
    <h1>About Vingilot</h1>
    <p>Client IP: <?php echo $_SERVER['REMOTE_ADDR']; ?></p>
    <a href="/">Home</a>
</body>
</html>
EOF

# Konfigurasi nginx untuk logging IP asli
cat > /etc/nginx/sites-available/default << 'EOF'
server {
    listen 80;
    server_name vingilot.k14.com app.k14.com;
    root /var/www/html;
    index index.php index.html;
    
    access_log /var/log/nginx/vingilot-access.log;
    
    location / {
        try_files $uri $uri/ =404;
    }
    
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
        fastcgi_param REMOTE_ADDR $http_x_real_ip;
    }
    
    location = /about {
        rewrite ^ /about.php last;
    }
}
EOF

chown -R www-data:www-data /var/www/html
nginx -t && systemctl restart nginx php8.4-fpm
