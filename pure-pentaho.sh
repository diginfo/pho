#!/bin/bash

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

PORT="-Dport=9898"
CACHE="/var/cache/pentaho"
#OPTS="-server -Xms512m -Xmx1024m -Xms512m -Xmx1024m"
OPTS="-server -Dmaxrun=60000"
#LOGS="-Dlog4j.configuration=purepentaho/log4j.properties"
#LOGS="-Dlog4j.configuration=file:log4j.dev.properties"
LOGS="-Dlog4j.configuration=file:log4j.properties"

EHOFF="-Dnet.sf.ehcache.disabled=true"
EHPATH="-Dnet.sf.ehcache.config.location=../ehcache.xml"

if [ ! -d "$CACHE" ]; then
  mkdir -p $CACHE;
  chmod 777 $CACHE
fi

function logbackup {
  NOW=`date +%y%m%d%H%M`
  ## Backup the logs
  cp -p $ROOT/log/pure-pentaho.log $ROOT/log/pure-pentaho.$NOW.log
}

function stop {
  cd "$(dirname "$0")"
  PID=$(pgrep -f "java -Dnet.sf.ehcache.disabled")
  if [ ! -z "$PID" ]; then
    while kill -9 $PID 2>/dev/null; do 
      echo "Waiting for $PID stop..."
      sleep 1
    done
  fi
}

function status {
  UP=$(ps aux | grep [P]urePentaho)  
  if [ -z "$UP" ]; then
    STATUS="stopped"
  else
    STATUS="running"
  fi
}

function start {
  
  ## TEST IF RUNNING
  status;
  if [[ $STATUS == "running" ]]; then
    exit 0;
  fi
  
  logbackup;
  
  ## Execute .jar file
  cd "$(dirname "$0")"
  /usr/bin/java $EHOFF $OPTS $PORT $LOGS -jar PurePentaho.jar &>/dev/null &
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
    exit 0;
      
  elif [[ $1 == "stop" ]]; then
    stop
    exit 0;
      
  elif [[ $1 == "restart" ]]; then
    restart
    exit 0;

  elif [[ $1 == "status" ]]; then
    status
    echo "$STATUS";
    exit 0;

  else
    exit 1
  
  fi

else
  exit 0;
fi