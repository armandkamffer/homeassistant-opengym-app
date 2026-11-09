#!/bin/sh
set -eu
OPT=/data/options.json
opt() { jq -r --arg k "$1" '.[$k] // empty' "$OPT"; }
flag() { [ "$(opt "$1")" = "true" ] && echo 1 || echo 0; }

mkdir -p /data/opengym /etc/nginx/conf.d
export DATA_DIR=/data/opengym
export PORT=3000
export TRUST_PROXY=1
export RP_ID="$(opt rp_id)"
export ORIGIN="$(opt origin)"
export DEFAULT_LANG="$(opt default_lang)"
export FIRST_USER_ADMIN="$(flag first_user_admin)"
export INVITE_ONLY="$(flag invite_only)"
export PASSWORD_LOGIN="$(flag password_login)"
export ALLOW_GUEST="$(flag allow_guest)"
export COACH_DISABLED="$(flag coach_disabled)"

# Render nginx config from the upstream template (same defaults as the web image)
export NGINX_PORT=8080 BACKEND=127.0.0.1 RESOLVER=127.0.0.1 BASE_PATH="" \
  CF_CONNECTING_IP="" MEDIA_UPLOAD_MAX=48m
export CONTENT_SECURITY_POLICY="default-src 'self'; script-src 'self' 'sha256-xUZtZS1nWJaAyUqA7ZKgkLhjdEisnY0MiRmax16aGFg='; style-src 'self' 'unsafe-inline'; img-src 'self' data: blob: https:; media-src 'self' blob: https:; font-src 'self' data:; connect-src 'self' https: http:; worker-src 'self'; manifest-src 'self'; frame-src https://www.youtube-nocookie.com; object-src 'none'; base-uri 'self'; form-action 'self'; frame-ancestors 'none'"
envsubst '${NGINX_PORT} ${BACKEND} ${PORT} ${RESOLVER} ${BASE_PATH} ${CF_CONNECTING_IP} ${MEDIA_UPLOAD_MAX} ${CONTENT_SECURITY_POLICY}' \
  < /etc/nginx/default.conf.template > /etc/nginx/conf.d/default.conf

cd /app
node server.js &
API=$!
nginx -g 'daemon off;' &
NGINX=$!
trap 'kill $API $NGINX 2>/dev/null' TERM INT
# Exit (so the Supervisor restarts the app) as soon as either process dies
while kill -0 $API 2>/dev/null && kill -0 $NGINX 2>/dev/null; do sleep 2; done
kill $API $NGINX 2>/dev/null || true
exit 1
