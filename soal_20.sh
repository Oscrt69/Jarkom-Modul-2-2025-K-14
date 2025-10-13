#!/bin/bash

# Buat halaman beranda Sirion
echo "Membuat halaman beranda Sirion..."

# Update konfigurasi Sirion untuk halaman beranda
cat > /etc/nginx/sites-available/sirion.conf << 'EOF'
# Redirect semua akses non-www ke www.k-14.com
server {
    listen 5151;
    server_name sirion.k-14.com 10.15.43.32 havens.k-14.com;
    return 301 http://www.k-14.com$request_uri;
}

# Konfigurasi utama untuk www.k-14.com
server {
    listen 5151;
    server_name www.k-14.com;
    
    root /var/www/sirion;
    index index.html;
    
    # Include basic auth configuration
    include /etc/nginx/conf.d/admin-auth.conf;
    
    # Path-based routing
    location /static/ {
        proxy_pass http://10.15.43.32:5209/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location /app/ {
        proxy_pass http://10.15.43.32:5526/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# Buat halaman beranda
mkdir -p /var/www/sirion
cat > /var/www/sirion/index.html << 'EOF'
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>War of Wrath: Lindon Bertahan</title>
    <style>
        body {
            font-family: 'Times New Roman', serif;
            margin: 0;
            padding: 20px;
            background-color: #f4f4f4;
            color: #333;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #8B4513;
            text-align: center;
            border-bottom: 2px solid #8B4513;
            padding-bottom: 10px;
        }
        .nav-links {
            text-align: center;
            margin: 30px 0;
        }
        .nav-links a {
            display: inline-block;
            margin: 0 15px;
            padding: 10px 20px;
            background: #8B4513;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            transition: background 0.3s;
        }
        .nav-links a:hover {
            background: #A0522D;
        }
        .content {
            line-height: 1.6;
        }
        footer {
            text-align: center;
            margin-top: 30px;
            color: #666;
            font-style: italic;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>War of Wrath: Lindon Bertahan</h1>
        
        <div class="content">
            <p>Di tepi barat Beleriand yang hampir tenggelam, Lindon berdiri sebagai benteng terakhir. 
            Di sini, kisah-kisah heroik dan tragedi bertemu, menciptakan warisan yang akan dikenang 
            sepanjang zaman.</p>
            
            <p>Jelajahi arsip-arsip kuno dan kisah-kisah dinamis dari dunia Middle-earth yang legendaris.</p>
        </div>
        
        <div class="nav-links">
            <a href="/app">Jelajahi Kisah Dinamis (Vingilot)</a>
            <a href="/static">Telusuri Arsip Statis (Lindon)</a>
        </div>
        
        <footer>
            <p>Pelabuhan Sirion - Gerbang menuju dunia legenda</p>
            <p>Kelompok K-14 - Komdat Jarkom 2025</p>
        </footer>
    </div>
</body>
</html>
EOF

# Set permissions
chown -R www-data:www-data /var/www/sirion

# Restart nginx
nginx -s stop 2>/dev/null || true
nginx

echo "Halaman beranda Sirion berhasil dibuat!"
echo "Silakan akses melalui: http://www.k-14.com:5151"