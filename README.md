# Jarkom-Modul-2-2025-K-14

## Soal 1
### Konfigurasi Topologi Dasar & NAT (Eonwe)
Membuat router **EONWE** dengan NAT agar seluruh jaringan internal dapat mengakses internet.  
Konfigurasi meliputi:
- IP Forwarding  
- Setup interface `eth0` (NAT) dan `eth1–eth3` (internal subnet)
- Routing dan DNS resolver
- Konfigurasi iptables untuk NAT (POSTROUTING & FORWARD rules)

**File Script:** `setup_eonwe.sh`

---

## Soal 2
### Konfigurasi Client
Setup klien di masing-masing subnet:
- **Barat:** Earendil, Elwing  
- **Timur:** Cirdan, Elrond, Maglor  
- **DMZ:** Sirion, Lindon, Vingilot  

Semua dikonfigurasi dengan IP statis, default gateway menuju Eonwe, dan DNS sementara `192.168.122.1`.

**File Script:** `setup_client_[nama].sh`

---

## Soal 3
### DNS Master (Tirion - ns1)
Konfigurasi DNS Master menggunakan **Bind9** di **Tirion**:
- Domain: `K14.com`
- File zone: `/etc/bind/zones/db.K14.com`
- Menyimpan A record untuk semua host (router, klien, DMZ)
- Menyediakan akses transfer ke DNS slave (`192.218.3.3`)

**File Script:** `setup_tirion_ns1.sh`

---

## Soal 4
### DNS Slave (Valmar - ns2)
Konfigurasi **Valmar** sebagai DNS Slave dari Tirion:
- Menerima zone transfer dari `ns1`
- File zone tersimpan otomatis di `/var/cache/bind/`
- Menggunakan `type slave` dan `masters { 192.218.3.2; };`

**File Script:** `setup_valmar_ns2.sh`

---

## Soal 5
### Verifikasi Konektivitas & DNS
Pengujian:
- Ping antar subnet (Barat, Timur, DMZ)
- Ping ke internet (`8.8.8.8`)
- Resolusi DNS:
  ```bash
  nslookup K14.com
  nslookup earendil.K14.com
  dig K14.com
  host cirdan.K14.com

---

## Soal 6

### File Script
`soal6_check_zone_transfer.sh`

### Perintah Uji
```bash
bash soal6_check_zone_transfer.sh
```

## Soal 7
Tujuan
Menambahkan A Record dan CNAME Record baru pada domain K14.com untuk mengarahkan subdomain ke host di jaringan DMZ.

Deskripsi

### A Record:

> sirion.K14.com → 192.218.3.4

> lindon.K14.com → 192.218.3.5

> vingilot.K14.com → 192.218.3.6

### CNAME Record:

> www.K14.com → sirion.K14.com

> static.K14.com → lindon.K14.com

> app.K14.com → vingilot.K14.com

### File Script
```
soal7_update_zone_records.sh
```
### Perintah Uji
```
dig @192.218.3.2 www.K14.com +short
dig @192.218.3.2 static.K14.com +short
dig @192.218.3.2 app.K14.com +short
```

### Soal 8

Zone: 3.218.192.in-addr.arpa

### PTR Records:

> 192.218.3.4 → sirion.K14.com

> 192.218.3.5 → lindon.K14.com

> 192.218.3.6 → vingilot.K14.com

File Script
```
soal8_reverse_dns.sh
```
Perintah Uji
```
dig -x 192.218.3.4 +short
dig -x 192.218.3.5 +short
dig -x 192.218.3.6 +short
```

Output:
```
sirion.K14.com.
lindon.K14.com.
vingilot.K14.com.
```
### Soal 9
🎯 Tujuan
Membuat web server statis di Lindon menggunakan Nginx, menampilkan file HTML statis.

📘 Deskripsi
Domain: static.K14.com

Root: /var/www/static

Mengaktifkan autoindex untuk menampilkan direktori /annals/

Menjalankan server pada port default 80

📂 File Script
soal9_web_statis_lindon.sh

🧩 Perintah Uji
bash
Salin kode
curl http://static.K14.com
curl http://static.K14.com/annals/
⚙️ Soal 10 – Web Server Dinamis (Vingilot)
🎯 Tujuan
Membuat web server dinamis di Vingilot menggunakan Nginx + PHP-FPM agar dapat menjalankan file .php.

📘 Deskripsi
Domain: app.K14.com

Root: /var/www/app

File:

index.php → Menampilkan informasi umum

about.php → Menampilkan detail server atau identitas kelompok

Mengaktifkan PHP-FPM socket (/run/php/php7.4-fpm.sock)

📂 File Script
soal10_web_dinamis_vingilot.sh

🧩 Perintah Uji
bash
Salin kode
curl http://app.K14.com
curl http://app.K14.com/about.php
✅ Output Diharapkan
Menampilkan halaman PHP dinamis berisi teks atau informasi server.



## Soal 11
**File:** `soal_11.sh`  
Menjadikan Sirion sebagai **reverse proxy** yang mem-forward:
- `/static/` → **Lindon (10.15.43.38)**  
- `/app/` → **Vingilot (10.15.43.39)**  

**Langkah otomatis:**
- Install Nginx  
- Backup konfigurasi default  
- Membuat konfigurasi path-based reverse proxy  
- Membuat halaman utama gateway  

**Output:**  
Sirion melayani permintaan `http://sirion.k14.com` dan meneruskan request ke server lain sesuai path.

---

## Soal 12
**File:** `soal_12.sh`  
Menambahkan **proteksi login (Basic Auth)** pada direktori `/admin/`.

Langkah otomatis:
- Install `apache2-utils` untuk `htpasswd`  
- Buat direktori `/var/www/admin`  
- Buat user & password (`admin` / `admin123`)  
- Update konfigurasi Nginx agar hanya `/admin` yang dilindungi  

Output:  
Saat mengakses `http://sirion.k14.com/admin`, pengguna diminta login.

---

## Soal 13
**File:** `soal_13.sh`  
Menambahkan konfigurasi **redirect permanen (301)** dari domain tanpa `www` ke `www.k14.com`.

Langkah otomatis:
- Update Nginx untuk:
  - Redirect `sirion.k14.com` dan IP → `www.k14.com`  
  - Melayani seluruh konten di `www.k14.com`  

Output:  
Akses `sirion.k14.com` otomatis diarahkan ke `www.k14.com`.

---

## Soal 14 
**File:** `soal_14.sh`  
Menampilkan **IP asli client** pada aplikasi dinamis di Vingilot.

**Langkah otomatis:**
- Install Nginx dan PHP-FPM  
- Membuat halaman `index.php` dan `about.php` menampilkan:
  - `REMOTE_ADDR`  
  - `X-Real-IP`  
  - `X-Forwarded-For`  
- Konfigurasi Nginx agar log mencatat IP asli dari proxy  

**Output:**  
Akses `http://vingilot.k14.com` akan menampilkan IP asli user di halaman web.

---

## Soal 15
**File:** `soal_15.sh`  
Melakukan **benchmark HTTP** menggunakan `ApacheBench (ab)` terhadap endpoint:
- `/app/` (dynamic)
- `/static/` (static)

**Langkah otomatis:**
- Install `apache2-utils`  
- Jalankan `ab` dengan 500 request dan 10 concurrent users  
- Menampilkan hasil `Complete requests`, `Failed requests`, `Requests per second`, `Time per request`  

**Output:**  
Laporan performa disimpan di `/tmp/ab_app.txt` dan `/tmp/ab_static.txt`.

---

## Soal 16
**File:** `soal_16.sh`  
Mengubah alamat IP Lindon serta TTL pada zone file DNS.  

**Langkah otomatis:**
- Backup zone file `k14.com.zone`  
- Ganti IP Lindon → `10.15.43.40`  
- Ubah TTL menjadi **30 detik**  
- Restart BIND9  

**Output:**  
Perubahan DNS segera berlaku dan dapat diuji dengan `nslookup`.

---

## Soal 17
**File:** `soal_17.sh`  
Mengatur agar service penting **otomatis berjalan saat booting**.

**Langkah otomatis per node:**
| Node | Service |
|------|----------|
| Tirion, Valmar | bind9 |
| Sirion, Lindon | nginx |
| Vingilot | nginx + php8.4-fpm |

**Output:**  
Semua service utama aktif otomatis setelah reboot.

---

## Soal 18
**File:** `soal_18.sh`  
Menambahkan record DNS baru pada zone `k14.com`.

**Isi record baru:**
```dns
melkor  IN  TXT   "Morgoth (Melkor)"
morgoth IN  CNAME melkor
```

**Output:**  
Testing dengan:
```bash
nslookup -type=TXT melkor.k14.com
nslookup -type=CNAME morgoth.k14.com
```

---

## Soal 19
**File:** `soal_19.sh`  
Melakukan **uji resolusi DNS dan validasi konten web** pada CNAME baru `havens.k14.com`.

**Langkah otomatis:**
- `nslookup havens.k14.com`
- `curl` untuk cek HTTP response  
- Membandingkan `<title>` halaman antara `havens.k14.com` dan `www.k14.com`

**Output:**  
Jika judul halaman sama, berarti CNAME berfungsi dengan benar.

---

## Soal 20
**File:** `soal_20.sh`  
Membuat halaman web utama yang menampilkan tema **“War of Wrath: Lindon Bertahan”** dengan dua card:

- **Arsip Statis Lindon** → `/static/`  
- **Aplikasi Dinamis Vingilot** → `/app/`

**Langkah otomatis:**
- Membuat file `/var/www/html/index.html` dengan tampilan artistik HTML + CSS  
- Menampilkan tombol akses menuju dua layanan utama

Output:  
Halaman dapat diakses di:  
`http://www.k14.com`

Langkah Uji: verify_koneksi_dns.sh
---


