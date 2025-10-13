#!/bin/bash

# Script untuk ApacheBench testing dari Elrond
echo "Melakukan ApacheBench testing..."

# Install apache2-utils untuk ab
apt update
apt install -y apache2-utils

# Buat direktori untuk hasil test
mkdir -p /root/benchmark_results

echo "=== Testing endpoint /app/ ===" > /root/benchmark_results/ab_results.txt
ab -n 500 -c 10 http://www.k-14.com:5151/app/ >> /root/benchmark_results/ab_results.txt 2>&1

echo -e "\n\n=== Testing endpoint /static/ ===" >> /root/benchmark_results/ab_results.txt
ab -n 500 -c 10 http://www.k-14.com:5151/static/ >> /root/benchmark_results/ab_results.txt 2>&1

# Tampilkan ringkasan hasil
echo "Hasil ApacheBench:"
echo "=================="
grep -E "(Time taken|Complete requests|Failed requests|Requests per second|Time per request)" /root/benchmark_results/ab_results.txt

echo "Detail hasil disimpan di: /root/benchmark_results/ab_results.txt"