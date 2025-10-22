#!/bin/bash

# Fix Zone Transfer Valmar - Force Method
# Jalankan di: VALMAR

echo "=========================================="
echo "Force Zone Transfer - VALMAR"
echo "=========================================="
echo ""

# Step 1: Stop bind9
echo "Step 1: Stopping bind9..."
killall named 2>/dev/null
killall -9 named 2>/dev/null
sleep 2
echo "✓ bind9 stopped"

# Step 2: Hapus semua cache zone
echo ""
echo "Step 2: Removing ALL zone cache..."
rm -rf /var/cache/bind/*
echo "✓ Cache cleared"

# Step 3: Verify Tirion is reachable
echo ""
echo "Step 3: Testing connection to Tirion..."
ping -c 2 192.218.3.2
if [ $? -ne 0 ]; then
    echo "✗ Cannot reach Tirion!"
    exit 1
fi
echo "✓ Tirion reachable"

# Step 4: Query Tirion directly
echo ""
echo "Step 4: Checking Tirion's current data..."
echo "SOA from Tirion:"
dig @192.218.3.2 K14.com SOA +short
echo ""
echo "lindon.K14.com from Tirion:"
dig @192.218.3.2 lindon.K14.com +short

# Step 5: Reconfigure slave (pastikan benar)
echo ""
echo "Step 5: Reconfiguring slave zones..."

cat > /etc/bind/named.conf.local << 'EOF'
zone "K14.com" {
    type slave;
    file "/var/cache/bind/db.K14.com";
    masters { 192.218.3.2; };
};

zone "3.218.192.in-addr.arpa" {
    type slave;
    file "/var/cache/bind/db.192.218.3";
    masters { 192.218.3.2; };
};
EOF

echo "✓ Configuration written"

# Step 6: Check configuration
echo ""
echo "Step 6: Checking configuration..."
named-checkconf
if [ $? -ne 0 ]; then
    echo "✗ Configuration error!"
    exit 1
fi
echo "✓ Configuration OK"

# Step 7: Check Tirion's named.conf untuk allow-transfer
echo ""
echo "Step 7: Verifying Tirion allows transfer to 192.218.3.3..."
echo "(This should be configured on Tirion with: allow-transfer { 192.218.3.3; };)"
echo ""

# Step 8: Start bind9
echo "Step 8: Starting bind9..."
/usr/sbin/named -u bind -c /etc/bind/named.conf

if [ $? -ne 0 ]; then
    echo "✗ Failed to start bind9!"
    exit 1
fi
echo "✓ bind9 started"

# Step 9: Wait for zone transfer
echo ""
echo "Step 9: Waiting for automatic zone transfer..."
echo "Waiting 5 seconds..."
sleep 5

# Check if zone files exist
if [ -f /var/cache/bind/db.K14.com ]; then
    echo "✓ Forward zone transferred!"
else
    echo "⚠ Forward zone NOT yet transferred"
fi

if [ -f /var/cache/bind/db.192.218.3 ]; then
    echo "✓ Reverse zone transferred!"
else
    echo "⚠ Reverse zone NOT yet transferred"
fi

# Step 10: Force transfer with rndc if needed
echo ""
echo "Step 10: Forcing zone refresh with rndc..."
rndc refresh K14.com 2>/dev/null
rndc refresh 3.218.192.in-addr.arpa 2>/dev/null

echo "Waiting 5 more seconds..."
sleep 5

# Step 11: Check zone files again
echo ""
echo "Step 11: Checking zone files..."
ls -lh /var/cache/bind/

# Step 12: Verify zone data
echo ""
echo "Step 12: Verifying zone data..."
echo ""
echo "SOA from localhost:"
dig @localhost K14.com SOA +short

echo ""
echo "lindon.K14.com from localhost:"
dig @localhost lindon.K14.com +short

echo ""
echo "static.K14.com from localhost:"
dig @localhost static.K14.com +short

# Step 13: Verify from external
echo ""
echo "Step 13: Testing from external query..."
echo ""
echo "SOA from 192.218.3.3:"
dig @192.218.3.3 K14.com SOA +short

echo ""
echo "lindon.K14.com from 192.218.3.3:"
dig @192.218.3.3 lindon.K14.com +short

# Final check
echo ""
echo "=========================================="
VALMAR_SERIAL=$(dig @localhost K14.com SOA +short | awk '{print $3}')
TIRION_SERIAL=$(dig @192.218.3.2 K14.com SOA +short | awk '{print $3}')
LINDON_IP=$(dig @localhost lindon.K14.com +short)

echo "Final Status:"
echo "  Tirion Serial: $TIRION_SERIAL"
echo "  Valmar Serial: $VALMAR_SERIAL"
echo "  Lindon IP: $LINDON_IP"
echo ""

if [ "$TIRION_SERIAL" = "$VALMAR_SERIAL" ] && [ "$LINDON_IP" = "192.218.3.7" ]; then
    echo "✅ SUCCESS! Zone transfer completed!"
else
    echo "❌ FAILED! Zone transfer incomplete"
    echo ""
    echo "Troubleshooting:"
    echo "1. Check if Tirion allows transfer:"
    echo "   On Tirion, check /etc/bind/named.conf.local"
    echo "   Should have: allow-transfer { 192.218.3.3; };"
    echo ""
    echo "2. Restart bind9 on Tirion:"
    echo "   killall named && /usr/sbin/named -u bind -c /etc/bind/named.conf"
    echo ""
    echo "3. Then re-run this script on Valmar"
fi
echo "=========================================="
