echo "Monitor Docker Events" 

if test -f ".monitor.ini"; then
        source ".monitor.ini"

else
        echo "File .monitor.ini not exits"
        exit 0
fi



domain=$( echo $MONITOR_DOMAIN | tr -d "\r"  )
from=$( echo $MONITOR_FROM | tr  -d "\r" )
to=$MONITOR_TO
api_key=$( echo $MONITOR_APIKEY | tr -d  "\r" )

URL="https://api.mailgun.net/v3/$domain/messages"
server_name=$(hostname -f )


function ignoreContainer(){
  container_name=$1
  
  CONTAINERS=$(echo $MONITOR_IGNORE | tr ";" "\n" )
  for  container in $CONTAINERS
  do
        
        if [[ $container_name == *"$container"* ]]; then
        
                return 1
        fi

  done

  return 0
}

function sendMail(){
        container_name=$1
        echo ""
        timestamp=$(date +%s)
        log=$timestamp

        ignoreContainer "$container_name"
        isValid=$?
        
        if [[ "$isValid" -eq "0" ]]; then
                echo -n ""
        else
                return 
        fi
        
        docker logs --tail 50 ${container_name} &> "${timestamp}.log"

        to=" "
        MAILS=$(echo $MONITOR_TO | tr ";" "\n" )
        for  addr in $MAILS
        do
           addr=$( echo $addr | tr -d "\r"  )
           addr=$( echo $addr | tr -d "\n"  )
           
           to=" ${to} -F to='${addr}' "
        done

        req="curl --user 'api:${api_key}' '$URL' -F from='${from}' ${to} -F subject='Container started ${container_name} on ${server_name}' -F text='${log}' -F attachment='@${timestamp}.log' "

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
