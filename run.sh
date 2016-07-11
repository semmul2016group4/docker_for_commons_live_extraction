#!/usr/bin/env bash
function handle_trap {
	PID_LIVE=$(ps ax | grep java | grep org.dbpedia.extraction.live.main | tail -1 | sed -n -E 's/([0-9]+).*/\1/p' | xargs)
	echo "PID LIVE"
	echo $PID_LIVE
	kill -n 2 $PID_LIVE
	sleep 2s
        service mysql stop &
        exit 0;
}

trap handle_trap SIGTERM

if [ ! "$(ls -A /var/lib/mysql)" ]; then
  cp -a /mysqlbackup/. /var/lib/mysql
fi
service mysql start &&
cd extraction-framework/live &&\
../run live &
PID_JVM=$!
echo $PID_JVM
wait $PID_JVM
