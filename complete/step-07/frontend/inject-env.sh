#!/bin/sh

# nginx.conf가 템플릿 형태일 경우 환경변수로 치환
if [ -f /etc/nginx/conf.d/nginx.conf ]; then
	mv /etc/nginx/conf.d/nginx.conf /etc/nginx/conf.d/nginx.conf.template
fi
envsubst '${VITE_API_URL}' < /etc/nginx/conf.d/nginx.conf.template > /etc/nginx/conf.d/nginx.conf
nginx -g 'daemon off;'