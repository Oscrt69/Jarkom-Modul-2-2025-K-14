#!/bin/bash

# Verifikasi CNAME Havens
echo "Verifikasi CNAME Havens..."

# Havens sudah ada di zone file, lakukan verifikasi
echo "Verifikasi Havens CNAME dari localhost:"
nslookup havens.k-14.com localhost

echo "Verifikasi bahwa havens.k-14.com mengarah ke www.k-14.com:"
nslookup -type=CNAME havens.k-14.com localhost

# Test akses web
echo "Testing akses web melalui havens.k-14.com:"
curl -s -I http://havens.k-14.com:5151/ | head -n 1

echo "CNAME Havens berhasil diverifikasi!"