#!/bin/bash

DOMAIN=ARGUS
USER=root
TIBCO_HOME=/opt/tibco
PATH=/bin:/usr/bin:/sbin:/usr/sbin
NAME=tibcoadmin

start() {
# Start daemons.
echo "Starting Tibco Hawk"
/bin/su $USER -c"cd $TIBCO_HOME/tra/domain/$DOMAIN;./hawkagent_$DOMAIN 2>&1 | /usr/bin/logger -t $NAME" &
echo "done"
}

stop() {
# Stop daemons.
echo "Shutting down Tibco Hawk"
killall hawkagent_$DOMAIN
echo "done"
}

case "$1" in
  start)
        start
            ;;
  stop)
        stop
            ;;
  *)
        echo $"Usage: $0 {start|stop}"
        exit 2
esac

