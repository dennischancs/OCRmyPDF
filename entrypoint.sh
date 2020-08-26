#!/bin/sh
exec hug -f /app/hugweb/server.py -p 5250 & 
/app/watchdog
