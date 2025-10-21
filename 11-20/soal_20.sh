# Buat halaman beranda yang menarik
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <title>War of Wrath: Lindon Bertahan</title>
    <style>
        body {
            font-family: 'Georgia', serif;
            background: linear-gradient(135deg, #1a2a6c, #b21f1f, #fdbb2d);
            color: white;
            margin: 0;
            padding: 0;
            min-height: 100vh;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 2rem;
        }
        .header {
            text-align: center;
            background: rgba(0,0,0,0.7);
            padding: 3rem;
            border-radius: 15px;
            margin-bottom: 3rem;
        }
        .title {
            font-size: 3rem;
            color: #ffd700;
            margin-bottom: 1rem;
        }
        .content {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 2rem;
        }
        .card {
            background: rgba(0,0,0,0.8);
            padding: 2rem;
            border-radius: 10px;
            text-align: center;
            border: 2px solid #ffd700;
        }
        .btn {
            display: inline-block;
            padding: 12px 30px;
            background: #b21f1f;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            margin-top: 1rem;
            font-weight: bold;
        }
        .btn:hover {
            background: #8B0000;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1 class="title">War of Wrath: Lindon Bertahan</h1>
            <p>Pelabuhan Terakhir di Tengah Badai Peperangan</p>
        </div>
        
        <div class="content">
            <div class="card">
                <h2>🏛️ Arsip Static Lindon</h2>
                <p>Jelajahi arsip-arsip kuno dan sejarah Beleriand</p>
                <a href="/static/" class="btn">Masuk ke Arsip</a>
            </div>
            
            <div class="card">
                <h2>⚔️ Aplikasi Dinamis Vingilot</h2>
                <p>Naiki Vingilot dan saksikan kisah epik Middle-earth</p>
                <a href="/app/" class="btn">Naiki Vingilot</a>
            </div>
        </div>
    </div>
</body>
</html>
EOF
