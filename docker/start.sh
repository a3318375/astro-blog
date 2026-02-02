#!/bin/sh
node /usr/share/nginx/html/server/entry.mjs &
nginx -g "daemon off;"