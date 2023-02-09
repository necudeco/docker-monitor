#!/bin/bash
echo "Monitor Docker Events"

DIR=$( dirname "$0" )
source "${DIR}/.monitor.ini"

domain=$MONITOR_DOMAIN
from=$MONITOR_FROM
to=$MONITOR_TO
api_key=$MONITOR_APIKEY

URL="https://api.mailgun.net/v3/$domain/messages"
server_name=$(hostname -f )

function sendMail(){
        container_name=$1
        echo ""
        timestamp=$(date +%s)
        log=$timestamp
        #log=$(docker logs --tail 50 ${container_name})
        docker logs --tail 50 ${container_name} &> "${timestamp}.log"

        req="curl --user 'api:${api_key}' '$URL' -F from='${from}' -F to='${to}' -F subject='Container started ${container_name} on ${server_name}' -F text='${log}' -F attachment='@${timestamp}.log' "

        #echo "${req}"
        eval $req
        rm "${timestamp}.log"
}


docker events --filter 'type=container' --filter 'event=start' --format '{{.Actor.Attributes.name}}' |
while read container; do
      NOW="$(date)"
      echo " container ${container} started at ${NOW} " ;
      sendMail $container
done
