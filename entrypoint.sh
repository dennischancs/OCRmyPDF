#!/bin/sh
exec hug -f /app/server.py -p 5250 & 
/app/watchdog
