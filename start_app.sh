#!/bin/bash

# Local web application start script

CONF_FILE=$1
APPNAME=$2
. $CONF_FILE

# Check application status
if [ ! -f $APPS_DIR/$APPNAME/nginx.conf ]; then
	echo "Application $APPNAME does not exist"
	exit 1
elif [ -f $NGINX_DIR/$APPNAME.conf ]; then
    echo "Application is already started"
    exit 0
else
	echo "Starting an application"
fi


# Get free port for the application
function scanner {
	for ((port=$MIN_PORT; port<=$MAX_PORT; port++)); do
		local res=`(echo >/dev/tcp/0.0.0.0/$port)> /dev/null 2>&1 && echo 0 || echo $port`
		if ((res != 0)); then
			echo $res
			return
		fi
    done
}

PORT=$(scanner)

if ((PORT == 0)); then
	echo "Could not start new application, ports pool if already fulfilled"
	exit 1
fi

mkdir -p $LOGS_DIR/$USER/$APPNAME
mkdir -p $PIDS_DIR/$USER/$APPNAME
chown -R $USER:$GROUP $PIDS_DIR/$USER/$APPNAME
echo "Application port is '$PORT'"

cat $APPS_DIR/$APPNAME/nginx.conf | sed -e "s|{{logs_dir}}|$LOGS_DIR|g" | sed -e "s|{{username}}|$USER|g" | sed -e "s|{{port}}|$PORT|g" | sed -e "s|{{apps_root}}|$APPS_DIR|g" > $NGINX_DIR/$APPNAME.conf
eval "$NGINX_CMD"
nohup sudo -u $USER ./exonic --url "http://localhost:$PORT" --application-name "$APPNAME" --pid-location "$PIDS_DIR/$USER/$APPNAME" &
