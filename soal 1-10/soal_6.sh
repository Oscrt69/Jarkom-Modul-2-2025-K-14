#!/bin/bash

# SOAL 6: Verifikasi Zone Transfer Tirion → Valmar
# Jalankan di: Tirion atau Valmar atau klien manapun

echo "=========================================="
echo "SOAL 6: Verifikasi Zone Transfer"
echo "=========================================="
echo ""

echo "Checking SOA serial from Tirion (ns1)..."
echo "----------------------------------------"
NS1_SERIAL=$(dig @192.218.3.2 K14.com SOA +short | awk '{print $3}')
echo "ns1 (Tirion) serial: $NS1_SERIAL"
echo ""

echo "Checking SOA serial from Valmar (ns2)..."
echo "----------------------------------------"
NS2_SERIAL=$(dig @192.218.3.3 K14.com SOA +short | awk '{print $3}')
echo "ns2 (Valmar) serial: $NS2_SERIAL"
echo ""

echo "=========================================="
if [ "$NS1_SERIAL" = "$NS2_SERIAL" ]; then
    echo "✅ SOAL 6 SELESAI!"
    echo "Zone transfer BERHASIL!"
    echo "Serial SOA sama: $NS1_SERIAL"
else
    echo "❌ Zone transfer GAGAL!"
    echo "Serial berbeda:"
    echo "  ns1: $NS1_SERIAL"
    echo "  ns2: $NS2_SERIAL"
fi
echo "=========================================="
echo ""

echo "Full SOA records:"
echo "From ns1:"
dig @192.218.3.2 K14.com SOA
echo ""
echo "From ns2:"
dig @192.218.3.3 K14.com SOA
