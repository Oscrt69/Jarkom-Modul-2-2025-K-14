# Jarkom-Modul-2-2025-K-14

## Soal 1

## Soal 2

## Soal 3

## Soal 4

## Soal 5 

## Soal 6

## Soal 7

## Soal 8

## Soal 9

## Soal 10

---

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

##Soal 15
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

##Soal 17
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

##Soal 18
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

##Soal 19
**File:** `soal_19.sh`  
Melakukan **uji resolusi DNS dan validasi konten web** pada CNAME baru `havens.k14.com`.

**Langkah otomatis:**
- `nslookup havens.k14.com`
- `curl` untuk cek HTTP response  
- Membandingkan `<title>` halaman antara `havens.k14.com` dan `www.k14.com`

**Output:**  
Jika judul halaman sama, berarti CNAME berfungsi dengan benar.

---

##Soal 20
**File:** `soal_20.sh`  
Membuat halaman web utama yang menampilkan tema **“War of Wrath: Lindon Bertahan”** dengan dua card:

- **Arsip Statis Lindon** → `/static/`  
- **Aplikasi Dinamis Vingilot** → `/app/`

**Langkah otomatis:**
- Membuat file `/var/www/html/index.html` dengan tampilan artistik HTML + CSS  
- Menampilkan tombol akses menuju dua layanan utama

Output:  
Halaman dapat diakses di:  
👉 `http://www.k14.com`

---
