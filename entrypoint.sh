#!/bin/sh

# Get Public IP on AWS EC2 Instance
TOKEN=`curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
export INSTANCE_IP=$(curl -s 169.254.169.254/latest/meta-data/public-ipv4 -H "X-aws-ec2-metadata-token: $TOKEN")
echo "InstanceIP: $INSTANCE_IP"

#Update Cloudflare DNS Route
curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records/$CLOUDFLARE_ROUTE_ID" \
  -H "Authorization: Bearer $CLOUDFLARE_API" \
  -H "Content-Type: application/json" \
  --data "{\"type\":\"A\",\"name\":\"$CLOUDFLARE_ROUTE\",\"content\":\"$INSTANCE_IP\",\"proxied\":true}"

# Get the CloudFlare Origin Certificate from environment variable
echo "$CLOUDFLARE_ORIGIN_CERT" > /etc/nginx/cert.pem

# Get the CloudFlare Origin Certificate Key from environment variable
echo "$CLOUDFLARE_ORIGIN_KEY" > /etc/nginx/cert.key

# Replace the UPSTREAM_HOST placeholder with the value of the environment variable
sed -i "s/UPSTREAM_HOST/${UPSTREAM_HOST}/g" /etc/nginx/nginx.conf

# Replace the Web-ID in nginx.conf with the actual Web-ID from the environment variable
sed -i "s/ID_PLACEHOLDER/${ID}/g" /etc/nginx/nginx.conf

# Get the Local SSL Certificate from environment variable
echo "$LOCAL_SSL_CERT" > /etc/nginx/local_cert.pem

# Get the Local SSL Certificate Key from environment variable
echo "$LOCAL_SSL_KEY" > /etc/nginx/local_cert.key

# Start NGINX
nginx -g "daemon off;"