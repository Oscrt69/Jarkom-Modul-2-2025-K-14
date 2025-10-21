#!/bin/bash
echo "=== SOAL 15: PERFORMANCE TESTING DENGAN APACHEBENCH ==="

# Install ApacheBench
apt update && apt install -y apache2-utils

ab -n 500 -c 10 http://www.k14.com/app/ > /tmp/ab_app.txt 2>&1

ab -n 500 -c 10 http://www.k14.com/static/ > /tmp/ab_static.txt 2>&1

# Tampilkan hasil
grep -E "(Complete requests|Failed requests|Requests per second|Time per request)" /tmp/ab_app.txt

grep -E "(Complete requests|Failed requests|Requests per second|Time per request)" /tmp/ab_static.txt
