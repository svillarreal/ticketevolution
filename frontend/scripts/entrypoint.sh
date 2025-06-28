#!/bin/sh

cat <<EOF > /usr/share/nginx/html/env.js
window.env = {
  VITE_API_BASE_URL: "${VITE_API_BASE_URL}"
};
EOF

exec nginx -g 'daemon off;'
