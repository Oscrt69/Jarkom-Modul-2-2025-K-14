#!/bin/bash

# SOAL 17: Autostart nginx & PHP-FPM di VINGILOT (Web Dinamis)
# Jalankan di: VINGILOT

echo "=========================================="
echo "SOAL 17: Setup Autostart - VINGILOT"
echo "=========================================="
echo ""

# Check nginx
if ! which nginx >/dev/null 2>&1; then
    echo "✗ nginx not installed!"
    exit 1
fi
echo "✓ nginx installed"

# Detect PHP version - IMPROVED DETECTION
if [ -f /usr/sbin/php-fpm8.4 ]; then
    PHP_VERSION="8.4"
elif [ -f /usr/sbin/php-fpm8.2 ]; then
    PHP_VERSION="8.2"
elif [ -f /usr/sbin/php-fpm8.1 ]; then
    PHP_VERSION="8.1"
elif [ -f /usr/sbin/php-fpm7.4 ]; then
    PHP_VERSION="7.4"
else
    # Try which command
    if which php-fpm8.4 >/dev/null 2>&1; then
        PHP_VERSION="8.4"
    elif which php-fpm8.2 >/dev/null 2>&1; then
        PHP_VERSION="8.2"
    elif which php-fpm8.1 >/dev/null 2>&1; then
        PHP_VERSION="8.1"
    elif which php-fpm7.4 >/dev/null 2>&1; then
        PHP_VERSION="7.4"
    else
        echo "✗ PHP-FPM not found!"
        exit 1
    fi
fi

echo "✓ PHP $PHP_VERSION-FPM installed"

# Enable nginx autostart
echo ""
echo "Enabling nginx autostart..."

# Method 1: Using systemctl (if available)
if which systemctl >/dev/null 2>&1; then
    systemctl enable nginx 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✓ nginx enabled via systemctl"
    fi
fi

# Method 2: Using update-rc.d (Debian/Ubuntu)
if which update-rc.d >/dev/null 2>&1; then
    update-rc.d nginx defaults 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✓ nginx enabled via update-rc.d"
    fi
fi

# Enable PHP-FPM autostart
echo ""
echo "Enabling PHP-FPM autostart..."

# Method 1: Using systemctl
if which systemctl >/dev/null 2>&1; then
    systemctl enable php${PHP_VERSION}-fpm 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✓ PHP-FPM enabled via systemctl"
    fi
fi

# Method 2: Using update-rc.d
if which update-rc.d >/dev/null 2>&1; then
    update-rc.d php${PHP_VERSION}-fpm defaults 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✓ PHP-FPM enabled via update-rc.d"
    fi
fi

# Add to rc.local as fallback
if [ -f /etc/rc.local ]; then
    # Remove old entries
    sed -i '/service php.*-fpm start/d' /etc/rc.local
    sed -i '/service nginx start/d' /etc/rc.local
    sed -i '/exit 0/d' /etc/rc.local
fi

cat >> /etc/rc.local << EOFRC
# Start PHP-FPM
service php${PHP_VERSION}-fpm start

# Start nginx
service nginx start

exit 0
EOFRC

chmod +x /etc/rc.local
echo "✓ Added to rc.local"

# Verify current status
echo ""
echo "Current service status:"

# Check PHP-FPM - IMPROVED CHECK
PHP_FPM_RUNNING=false

# Try multiple ways to check if PHP-FPM is running
if service php${PHP_VERSION}-fpm status 2>/dev/null | grep -q "running\|active"; then
    echo "✓ PHP-FPM is currently RUNNING"
    PHP_FPM_RUNNING=true
elif pidof php-fpm${PHP_VERSION} >/dev/null 2>&1; then
    echo "✓ PHP-FPM is currently RUNNING"
    PHP_FPM_RUNNING=true
elif pgrep -f "php-fpm.*${PHP_VERSION}" >/dev/null 2>&1; then
    echo "✓ PHP-FPM is currently RUNNING"
    PHP_FPM_RUNNING=true
else
    echo "⚠ PHP-FPM is NOT running, starting now..."
    service php${PHP_VERSION}-fpm start
    sleep 2
    if pidof php-fpm${PHP_VERSION} >/dev/null 2>&1 || pgrep -f "php-fpm.*${PHP_VERSION}" >/dev/null 2>&1; then
        echo "✓ PHP-FPM started successfully"
        PHP_FPM_RUNNING=true
    fi
fi

# Check nginx
if pidof nginx >/dev/null 2>&1; then
    echo "✓ nginx is currently RUNNING"
else
    echo "⚠ nginx is NOT running, starting now..."
    service nginx start
    sleep 2
    if pidof nginx >/dev/null 2>&1; then
        echo "✓ nginx started successfully"
    fi
fi

# Check ports
if ss -tulpn | grep :80 >/dev/null 2>&1; then
    echo "✓ nginx listening on port 80"
else
    echo "✗ nginx NOT listening on port 80"
fi

# Check PHP-FPM socket
SOCKET=$(ls /var/run/php/php*-fpm.sock /run/php/php*-fpm.sock 2>/dev/null | head -1)
if [ -S "$SOCKET" ]; then
    echo "✓ PHP-FPM socket exists: $SOCKET"
else
    echo "✗ PHP-FPM socket not found"
fi

# Test nginx config
echo ""
echo "Testing nginx configuration:"
nginx -t

# Test PHP application
echo ""
echo "Testing PHP application:"
curl -s http://localhost | grep -i "vingilot\|PHP Version" | head -3

echo ""
echo "=========================================="
echo "✅ SOAL 17 - VINGILOT SELESAI!"
echo "=========================================="
echo ""
echo "nginx and PHP-FPM will now start automatically on reboot"
echo ""
echo "To verify after reboot:"
echo "  service php${PHP_VERSION}-fpm status"
echo "  pidof nginx"
echo "  ss -tulpn | grep :80"
echo "  curl http://app.K14.com"



di node TIRION 


cat > /root/soal_17.sh << 'EOF'
#!/bin/bash

# SOAL 17: Autostart bind9 di TIRION (ns1)
# Jalankan di: TIRION

echo "=========================================="
echo "SOAL 17: Setup Autostart - TIRION (ns1)"
echo "=========================================="
echo ""

# Check if bind9 is installed
if ! which named >/dev/null 2>&1; then
    echo "✗ bind9 not installed!"
    exit 1
fi
echo "✓ bind9 installed"

# Enable bind9 autostart
echo ""
echo "Enabling bind9 autostart..."

# Method 1: Using systemctl (if available)
if which systemctl >/dev/null 2>&1; then
    systemctl enable bind9 2>/dev/null || systemctl enable named 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✓ bind9 enabled via systemctl"
    fi
fi

# Method 2: Using update-rc.d (Debian/Ubuntu)
if which update-rc.d >/dev/null 2>&1; then
    update-rc.d bind9 defaults 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✓ bind9 enabled via update-rc.d"
    fi
fi

# Create init script if not exists
if [ ! -f /etc/init.d/bind9 ]; then
    echo "Creating bind9 init script..."
    cat > /etc/init.d/bind9 << 'EOFINIT'
#!/bin/sh
### BEGIN INIT INFO
# Provides:          bind9
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start bind9 at boot time
### END INIT INFO

case "$1" in
    start)
        /usr/sbin/named -u bind -c /etc/bind/named.conf
        ;;
    stop)
        killall named
        ;;
    restart)
        killall named
        sleep 2
        /usr/sbin/named -u bind -c /etc/bind/named.conf
        ;;
    *)
        echo "Usage: $0 {start|stop|restart}"
        exit 1
        ;;
esac
exit 0
EOFINIT
    chmod +x /etc/init.d/bind9
    echo "✓ Init script created"
fi

# Add to rc.local as fallback
if [ -f /etc/rc.local ]; then
    # Remove old entries
    sed -i '/named -u bind/d' /etc/rc.local
    sed -i '/exit 0/d' /etc/rc.local
fi

cat >> /etc/rc.local << 'EOFRC'
# Start bind9
/usr/sbin/named -u bind -c /etc/bind/named.conf
exit 0
EOFRC

chmod +x /etc/rc.local
echo "✓ Added to rc.local"

# Verify current status
echo ""
echo "Current bind9 status:"
if pidof named >/dev/null 2>&1; then
    echo "✓ bind9 is currently RUNNING"
else
    echo "⚠ bind9 is NOT running, starting now..."
    /usr/sbin/named -u bind -c /etc/bind/named.conf
    sleep 2
    if pidof named >/dev/null 2>&1; then
        echo "✓ bind9 started successfully"
    fi
fi

# Check if listening
if ss -tulpn | grep :53 | grep named >/dev/null 2>&1; then
    echo "✓ bind9 listening on port 53"
else
    echo "✗ bind9 NOT listening on port 53"
fi

echo ""
echo "=========================================="
echo "✅ SOAL 17 - TIRION SELESAI!"
echo "=========================================="
echo ""
echo "bind9 will now start automatically on reboot"
echo ""
echo "To verify after reboot:"
echo "  pidof named"
echo "  ss -tulpn | grep :53"
echo "  dig @localhost K14.com"
EOF

chmod +x /root/soal_17.sh
./root/soal_17.sh

