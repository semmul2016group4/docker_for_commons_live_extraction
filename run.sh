#!/bin/sh

# Used to gracefully stop the DBpedia live extraction framework and the mysql database
# to ensue both are in sync when stopping the docker container
handle_trap() {
	# Getting Process ID of DBpedia live extraction framework
	echo "Stopping DBpedia live extraction framework."
	PID_LIVE=$(ps ax | grep java | grep org.dbpedia.extraction.live.main | tail -1 | sed -n -E 's/([0-9]+).*/\1/p' | xargs)
	kill -15 $PID_LIVE
	# Wait for DBpedia live extraction framework to exit
	sleep 3s

	echo "Stopping mysql database server."
        service mysql stop

	echo "System stopped gracefully."
        exit 0;
}

# Registering trap for SIGTERM
trap handle_trap 15

# Restore empty database schema if not present
if [ ! "$(ls -A /var/lib/mysql)" ]; then
  cp -a /mysqlbackup/. /var/lib/mysql
fi

echo "Starting mysql database server."
service mysql start &&

echo "Starting DBpedia live extraction framework."
../run live &
# Getting the process and waiting for it to ensure the trap will work
PID_RUN_SCRIPT=$!
wait $PID_RUN_SCRIPT
