#!/bin/bash

DOMAIN=ARGUS
USER=root
TIBCO_HOME=/opt/tibco
EMS_CONFIG=/opt/tibco/ems/6.0/bin/tibemsd.conf
PATH=/bin:/usr/bin:/sbin:/usr/sbin
NAME=tibcoadmin

start() {
# Start daemons.
echo "Starting Tibco EMS 6.0"
/bin/su $USER -c "cd $TIBCO_HOME/ems/6.0/bin;./tibemsd64 -config $EMS_CONFIG  2>&1 | /usr/bin/logger -t $NAME" &
echo "done"
}

stop() {
# Stop daemons.
echo "Shutting down Tibco EMS 6.0"
killall tibemsd64
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

