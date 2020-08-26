#!/bin/sh
nohup exec hug -f /app/hugweb/server.py >> /tmp/web-ocr.log 2>&1 & 
/app/watchdog
