#!/bin/bash

# SOAL 20 FINAL: Homepage Sirion - War of Wrath
# Jalankan di: SIRION

echo "=========================================="
echo "SOAL 20: Homepage Sirion (FINAL VERSION)"
echo "=========================================="
echo ""

# Stop nginx dulu
service nginx stop
sleep 2

# Hapus semua config lama
echo "Cleaning old configs..."
rm -f /etc/nginx/sites-enabled/*
rm -f /etc/nginx/sites-available/default
rm -f /etc/nginx/sites-available/sirion
rm -f /etc/nginx/sites-available/proxy
echo "✓ Old configs removed"

# Buat direktori homepage
mkdir -p /var/www/homepage
mkdir -p /var/www/admin

# Buat homepage HTML
echo ""
echo "Creating homepage..."
cat > /var/www/homepage/index.html << 'EOFHTML'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>War of Wrath: Lindon Bertahan</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #1e3c72 0%, #2a5298 50%, #7e8ba3 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        .container {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            padding: 50px;
            max-width: 800px;
            width: 100%;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            animation: fadeIn 1s ease-in;
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        h1 {
            color: #1e3c72;
            font-size: 2.5em;
            margin-bottom: 20px;
            text-align: center;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.1);
        }
        .subtitle {
            color: #555;
            text-align: center;
            font-size: 1.2em;
            margin-bottom: 30px;
            font-style: italic;
        }
        .description {
            color: #333;
            line-height: 1.8;
            margin-bottom: 40px;
            text-align: justify;
        }
        .links {
            display: flex;
            gap: 20px;
            justify-content: center;
            flex-wrap: wrap;
        }
        .link-card {
            flex: 1;
            min-width: 250px;
            padding: 30px;
            border-radius: 15px;
            text-align: center;
            text-decoration: none;
            color: white;
            transition: all 0.3s ease;
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        }
        .link-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 15px 30px rgba(0,0,0,0.3);
        }
        .link-card.app {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        .link-card.static {
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
        }
        .link-card h3 {
            font-size: 1.5em;
            margin-bottom: 10px;
        }
        .link-card p {
            font-size: 0.9em;
            opacity: 0.9;
        }
        .icon {
            font-size: 3em;
            margin-bottom: 15px;
        }
        .footer {
            margin-top: 40px;
            text-align: center;
            color: #666;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>⚔️ War of Wrath: Lindon Bertahan</h1>
        <p class="subtitle">Pelabuhan Terakhir di Beleriand</p>
        
        <div class="description">
            <p>Di tengah kehancuran Beleriand, Lindon berdiri tegak sebagai benteng terakhir. 
            Círdan sang pembuat kapal terus membangun armada di pelabuhan, 
            sementara Elrond dan para pejuang mempertahankan garis depan. 
            Sirion, sebagai gerbang utama, menjaga akses ke semua layanan penting.</p>
        </div>
        
        <div class="links">
            <a href="/app/" class="link-card app">
                <div class="icon">⛵</div>
                <h3>Vingilot</h3>
                <p>Dynamic Application</p>
                <p>Kapal Eärendil yang berlayar ke Valinor</p>
            </a>
            
            <a href="/static/" class="link-card static">
                <div class="icon">🏛️</div>
                <h3>Lindon Archives</h3>
                <p>Static Resources</p>
                <p>Arsip sejarah Beleriand yang tersimpan</p>
            </a>
        </div>
        
        <div class="footer">
            <p>🌊 Sirion - Gateway to the Havens | K14.com 🌊</p>
            <p>Komunikasi Data & Jaringan Komputer 2025</p>
        </div>
    </div>
</body>
</html>
EOFHTML

echo "✓ Homepage created"

# Buat admin page (untuk soal 12)
cat > /var/www/admin/index.html << 'EOFADMIN'
<!DOCTYPE html>
<html>
<head>
    <title>Admin Panel</title>
</head>
<body>
    <h1>Admin Panel</h1>
    <p>You have successfully authenticated!</p>
</body>
</html>
EOFADMIN

# Buat htpasswd jika belum ada (untuk soal 12)
if [ ! -f /etc/nginx/.htpasswd ]; then
    echo "Creating htpasswd..."
    apt-get install -y apache2-utils 2>/dev/null
    htpasswd -bc /etc/nginx/.htpasswd admin warofwrath 2>/dev/null
    echo "✓ htpasswd created (admin:warofwrath)"
fi

# Buat konfigurasi nginx FINAL
echo ""
echo "Creating nginx configuration..."

cat > /etc/nginx/sites-available/sirion << 'EOFNGINX'
# Server utama untuk www.K14.com
server {
    listen 80;
    server_name www.K14.com;

    # Homepage di root
    location = / {
        root /var/www/homepage;
        try_files /index.html =404;
    }

    # Serve homepage assets jika ada
    location /assets {
        root /var/www/homepage;
    }

    # Reverse proxy ke Vingilot (dynamic app)
    location /app {
        proxy_pass http://192.218.3.6;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Reverse proxy ke Lindon (static)
    location /static {
        proxy_pass http://192.218.3.7;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Admin area dengan Basic Auth
    location /admin {
        auth_basic "Admin Area - Restricted Access";
        auth_basic_user_file /etc/nginx/.htpasswd;
        root /var/www;
        index index.html;
        try_files $uri $uri/ =404;
    }

    access_log /var/log/nginx/sirion-access.log;
    error_log /var/log/nginx/sirion-error.log;
}

# Canonical redirect - redirect semua ke www.K14.com
server {
    listen 80 default_server;
    server_name sirion.K14.com 192.218.3.4 havens.K14.com _;

    return 301 http://www.K14.com$request_uri;
}
EOFNGINX

echo "✓ Configuration created"

# Enable configuration
ln -sf /etc/nginx/sites-available/sirion /etc/nginx/sites-enabled/sirion

# Test configuration
echo ""
echo "Testing nginx configuration..."
nginx -t

if [ $? -ne 0 ]; then
    echo "✗ Configuration error!"
    exit 1
fi
echo "✓ Configuration OK"

# Start nginx
echo ""
echo "Starting nginx..."
service nginx start

sleep 3

# Check status
if pidof nginx >/dev/null 2>&1; then
    echo "✓ nginx running"
else
    echo "✗ nginx not running!"
    exit 1
fi

echo ""
echo "=========================================="
echo "✅ SOAL 20 SELESAI!"
echo "=========================================="
echo ""

echo "Test dari KLIEN (Earendil/Cirdan):"
echo ""
echo "1. Homepage:"
echo "   curl http://www.K14.com"
echo ""
echo "2. Test link /app:"
echo "   curl http://www.K14.com/app/"
echo ""
echo "3. Test link /static:"
echo "   curl http://www.K14.com/static/"
echo ""
echo "4. Test redirect:"
echo "   curl -I http://sirion.K14.com"
echo "   curl -I http://havens.K14.com"
echo ""
echo "🎉 SEMUA SOAL (1-20) SELESAI! 🎉"
