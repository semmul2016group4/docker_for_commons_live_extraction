#!/bin/sh
if [ ! "$(ls -A /var/lib/mysql)" ]; then
  cp -a /mysqlbackup/. /var/lib/mysql
fi
sleep 30s
service mysql start
cd extraction-framework/live &&\
../run live  
