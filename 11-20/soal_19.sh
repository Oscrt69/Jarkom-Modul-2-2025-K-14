nslookup havens.k14.com localhost

curl -s -I http://havens.k14.com/ | head -n 3

www_title=$(curl -s http://www.k14.com/ | grep -o '<title>[^<]*' | head -1)
havens_title=$(curl -s http://havens.k14.com/ | grep -o '<title>[^<]*' | head -1)
echo "www.k14.com title: $www_title"
echo "havens.k14.com title: $havens_title"
    
