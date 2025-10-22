
cat > /root/soal_14.sh << 'EOF'
#!/bin/bash

echo "=========================================="
echo "SOAL 14: Configure Real IP Logging"
echo "=========================================="

# Detect PHP-FPM socket
SOCKET=$(ls /var/run/php/php*-fpm.sock 2>/dev/null | head -1)

if [ -z "$SOCKET" ]; then
    echo "❌ Cannot find PHP-FPM socket!"
    exit 1
fi

echo "✓ Found socket: $SOCKET"

# Backup config
cp /etc/nginx/sites-available/app /etc/nginx/sites-available/app.backup.$(date +%Y%m%d)

# Update nginx config
cat > /etc/nginx/sites-available/app << 'EOFNGINX'
# Custom log format untuk real IP
log_format real_ip '$http_x_real_ip - $remote_user [$time_local] '
                   '"$request" $status $body_bytes_sent '
                   '"$http_referer" "$http_user_agent"';

server {
    listen 80;
    server_name app.K14.com;

    root /var/www/app;
    index index.php index.html;

    # Set real IP dari X-Real-IP header
    set_real_ip_from 192.218.3.4;
    real_ip_header X-Real-IP;
    real_ip_recursive on;

    # PHP-FPM configuration
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:SOCKET_PATH;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_param REMOTE_ADDR $http_x_real_ip;
    }

    # Rewrite /about
    location /about {
        try_files $uri /about.php;
    }

    location / {
        try_files $uri $uri/ =404;
    }

    # Use custom log format
    access_log /var/log/nginx/app-access.log real_ip;
    error_log /var/log/nginx/app-error.log;
}
EOFNGINX

# Replace SOCKET_PATH dengan socket yang terdeteksi
sed -i "s|SOCKET_PATH|$SOCKET|g" /etc/nginx/sites-available/app

echo "✓ Config updated"

# Test config
nginx -t

if [ $? -ne 0 ]; then
    echo "❌ Config error! Restoring backup..."
    cp /etc/nginx/sites-available/app.backup.* /etc/nginx/sites-available/app 2>/dev/null
    exit 1
fi

echo "✓ Config OK"

# Reload nginx
service nginx reload

echo ""
echo "=========================================="
echo "✅ SOAL 14 SELESAI!"
echo "=========================================="
echo ""

# Clear log untuk test
> /var/log/nginx/app-access.log

echo "Log cleared. Ready for testing!"
echo ""
echo "Silakan akses dari klien:"
echo "  curl http://www.K14.com/app/"
echo ""
echo "Lalu cek log dengan:"
echo "  tail -10 /var/log/nginx/app-access.log"
echo ""
echo "IP yang tercatat harus IP klien asli,"
echo "BUKAN 192.218.3.4 (Sirion)"
EOF

chmod +x /root/soal_14.sh
./root/soal_14.sh
