#!/bin/sh
exec hug -f /app/server.py -p 80 & 
/app/watchdog
