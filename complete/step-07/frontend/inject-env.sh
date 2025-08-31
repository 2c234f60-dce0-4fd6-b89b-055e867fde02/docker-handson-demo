#!/bin/sh

# Replace placeholder in nginx config with actual backend URL
sed -i "s|BACKEND_URL_PLACEHOLDER|${VITE_API_URL}|g" /etc/nginx/conf.d/nginx.conf

# Start nginx
nginx -g "daemon off;"