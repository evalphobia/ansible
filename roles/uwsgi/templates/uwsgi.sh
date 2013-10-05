#!/bin/sh

### BEGIN INIT INFO
# Provides:          uwsgi
# Required-Start:    $all
# Required-Stop:     $all
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: starts the uwsgi app server
# Description:       starts uwsgi app server using start-stop-daemon
### END INIT INFO

PATH=/sbin:/usr/sbin:/bin:/usr/bin
PIDFILE=/var/run/uwsgi.pid

DAEMON=/home/{{ app.user }}/uwsgi/bin/uwsgi
DAEMON_OPTS="--emperor /etc/uwsgi/vassals/"

OWNER=root
NAME=uWSGI
DESC='uWSGI Emperor'
SCRIPTNAME=/etc/init.d/$NAME


test -x $DAEMON || exit 0

# Include uwsgi defaults if available
if [ -f /etc/default/$NAME ] ; then
    . /etc/default/$NAME
fi

. /lib/init/vars.sh
. /lib/lsb/init-functions

set -e

start(){
    log_daemon_msg "Starting $DESC: "
    start-stop-daemon --start --background --pidfile $PIDFILE --make-pidfile --chuid $OWNER:$OWNER --user $OWNER --exec $DAEMON -- $DAEMON_OPTS
    endMessage $? "$NAME Started."
}

stop(){
    log_daemon_msg "Stopping $DESC: "
    start-stop-daemon --stop --signal 3 --quiet --pidfile $PIDFILE --user $OWNER --retry 2 --exec $DAEMON
    endMessage $? "$NAME Stopped."
}

reload(){
    log_daemon_msg "Reloading $DESC" "$NAME"
    start-stop-daemon --stop --signal HUP --quiet --pidfile $PIDFILE --name $NAME --exec $DAEMON
    endMessage $? "$NAME Reloaded."
}

endMessage(){
    case "$1" in
        0) 
            log_end_msg 0
            echo $2
            ;;
        1) log_end_msg 1 ;;
        *) log_end_msg 1 ;;
    esac
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    reload)
        reload
        ;;
    restart)
        stop
        sleep 1
        start
        ;;
    status)  
        status_of_proc "$DAEMON" "$NAME" && exit 0 || exit $?
        ;;
      *)  
        echo "Usage: $SCRIPTNAME {start|stop|restart|reload|status}" >&2
        exit 1
        ;;
esac
exit 0
