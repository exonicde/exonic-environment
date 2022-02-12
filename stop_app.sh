#!/bin/bash

# Local web application stop script

CONF_FILE=$1
APPNAME=$2
. $CONF_FILE

# ToDo: Check program state for another users

OTHER_PIDS=($(ls run/*/exocalc/* | grep -v "$USER/"))
if [ $OTHER_PIDS ]; then
	echo "another users uses that program"
else
	echo "No another users using this application, stopping backend"
	rm -fr $NGINX_DIR/$APPNAME.conf
	eval "$NGINX_CMD"
fi

if [ ! -d "$PIDS_DIR/$USER/$APPNAME" ]; then
	echo "PIDS directory is not exists"
	exit 1
fi

PIDS=($(ls $PIDS_DIR/$USER/$APPNAME))
for PID in "${PIDS[@]}"; do
	if kill -0 $PID > /dev/null 2>&1; then
		kill -15 $PID
	fi
done

rm -fr $PIDS_DIR/$USER/$APPNAME
