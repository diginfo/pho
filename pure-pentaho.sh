#!/bin/bash

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

PORT="-Dport=9898"
CACHE="/var/cache/pentaho"
#OPTS="-server -Xms512m -Xmx1024m"
OPTS="-server -Dmaxrun=30000"
#LOGS="-Dlog4j.configuration=purepentaho/log4j.properties"
LOGS="-Dlog4j.configuration=file:log4j.properties"

EHOFF="-Dnet.sf.ehcache.disabled=false"
EHPATH="-Dnet.sf.ehcache.config.location=../ehcache.xml"

if [ ! -d "$CACHE" ]; then
  mkdir -p $CACHE;
  chmod 777 $CACHE
fi

function stop {
  ## Backup the logs
  cp -p $ROOT/log/pure-pentaho.log $ROOT/log/pure-pentaho.bak.log
  cd "$(dirname "$0")"
  pkill -f PurePentaho
}

function start {
  ## Execute .jar file
  cd "$(dirname "$0")"
  /usr/bin/java $EHOFF $EHPATH $OPTS $PORT $LOGS -jar PurePentaho.jar &
  ## Execute .class (remove package name from .java files)
  #java $OPTS $PORT $LOGS -cp ./lib/*:./run PurePentaho  
}

function restart {
  stop;
  sleep 1;
  start;
}

if [[ $1 ]]; then
	MSG=$1
  if [[ $1 == "start" ]]; then
    start
  
  elif [[ $1 == "stop" ]]; then
    stop
  
  elif [[ $1 == "restart" ]]; then
    restart

  else
    exit 1
  fi

else
  exit 0;
fi