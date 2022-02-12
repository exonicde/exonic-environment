#!/bin/bash
IP=$1
first_port=$2
last_port=$3
function scanner {
	for ((port=$first_port; port<=$last_port; port++)); do
		local res=`(echo >/dev/tcp/$IP/$port)> /dev/null 2>&1 && echo 0 || echo $port`
		if ((res != 0)); then
			echo $res
			return
		fi
    done
}

FREE_PORT=$(scanner)
echo $FREE_PORT
