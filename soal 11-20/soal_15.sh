cat > /root/soal_15.sh << 'EOF'
#!/bin/bash

echo "=========================================="
echo "SOAL 15: Load Testing dengan ApacheBench"
echo "=========================================="

# Install apache2-utils
echo "Installing apache2-utils..."
apt-get update -qq
apt-get install -y apache2-utils

if ! which ab >/dev/null 2>&1; then
    echo "❌ ab not found!"
    exit 1
fi

echo "✓ ApacheBench ready"

# Create results directory
mkdir -p /root/load-test-results

echo ""
echo "=========================================="
echo "Starting Load Tests..."
echo "=========================================="
echo ""

# Test 1: /app
echo "TEST 1: http://www.K14.com/app/"
echo "Parameters: 500 requests, concurrency 10"
echo "----------------------------------------"

ab -n 500 -c 10 http://www.K14.com/app/ > /root/load-test-results/app-test.txt 2>&1

if [ $? -eq 0 ]; then
    echo "✓ App test completed"
    echo ""
    grep "Requests per second" /root/load-test-results/app-test.txt
    grep "Time per request" /root/load-test-results/app-test.txt | head -1
    grep "Failed requests" /root/load-test-results/app-test.txt
    
    APP_RPS=$(grep "Requests per second" /root/load-test-results/app-test.txt | awk '{print $4}')
    APP_TIME=$(grep "Time per request" /root/load-test-results/app-test.txt | head -1 | awk '{print $4}')
    APP_FAILED=$(grep "Failed requests" /root/load-test-results/app-test.txt | awk '{print $3}')
else
    APP_RPS="FAILED"
    APP_TIME="FAILED"
    APP_FAILED="FAILED"
fi

echo ""
echo "=========================================="
echo ""

# Test 2: /static
echo "TEST 2: http://www.K14.com/static/"
echo "Parameters: 500 requests, concurrency 10"
echo "----------------------------------------"

ab -n 500 -c 10 http://www.K14.com/static/ > /root/load-test-results/static-test.txt 2>&1

if [ $? -eq 0 ]; then
    echo "✓ Static test completed"
    echo ""
    grep "Requests per second" /root/load-test-results/static-test.txt
    grep "Time per request" /root/load-test-results/static-test.txt | head -1
    grep "Failed requests" /root/load-test-results/static-test.txt
    
    STATIC_RPS=$(grep "Requests per second" /root/load-test-results/static-test.txt | awk '{print $4}')
    STATIC_TIME=$(grep "Time per request" /root/load-test-results/static-test.txt | head -1 | awk '{print $4}')
    STATIC_FAILED=$(grep "Failed requests" /root/load-test-results/static-test.txt | awk '{print $3}')
else
    STATIC_RPS="FAILED"
    STATIC_TIME="FAILED"
    STATIC_FAILED="FAILED"
fi

echo ""
echo "=========================================="
echo "✅ SOAL 15 SELESAI!"
echo "=========================================="
echo ""

# Create summary table
cat > /root/load-test-results/summary.txt << 'EOFSUM'
========================================
LOAD TEST SUMMARY - Elrond
Test Date: $(date)
========================================

Configuration:
- Total Requests: 500
- Concurrency Level: 10
- Test Client: Elrond (192.218.2.3)

----------------------------------------
RESULTS TABLE:
----------------------------------------

Endpoint: http://www.K14.com/app/
  Requests/sec:     APP_RPS_VALUE
  Time/request:     APP_TIME_VALUE ms
  Failed requests:  APP_FAILED_VALUE

Endpoint: http://www.K14.com/static/
  Requests/sec:     STATIC_RPS_VALUE
  Time/request:     STATIC_TIME_VALUE ms
  Failed requests:  STATIC_FAILED_VALUE

========================================
EOFSUM

# Replace placeholders
sed -i "s|APP_RPS_VALUE|$APP_RPS|g" /root/load-test-results/summary.txt
sed -i "s|APP_TIME_VALUE|$APP_TIME|g" /root/load-test-results/summary.txt
sed -i "s|APP_FAILED_VALUE|$APP_FAILED|g" /root/load-test-results/summary.txt
sed -i "s|STATIC_RPS_VALUE|$STATIC_RPS|g" /root/load-test-results/summary.txt
sed -i "s|STATIC_TIME_VALUE|$STATIC_TIME|g" /root/load-test-results/summary.txt
sed -i "s|STATIC_FAILED_VALUE|$STATIC_FAILED|g" /root/load-test-results/summary.txt

cat /root/load-test-results/summary.txt

echo ""
echo "Files saved:"
echo "  - /root/load-test-results/summary.txt"
echo "  - /root/load-test-results/app-test.txt"
echo "  - /root/load-test-results/static-test.txt"
echo ""
echo "To view full reports:"
echo "  cat /root/load-test-results/app-test.txt"
echo "  cat /root/load-test-results/static-test.txt"

EOF

chmod +x /root/soal_15.sh
./root/soal_15.sh
