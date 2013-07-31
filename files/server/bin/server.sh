#!/bin/sh
#
# Startup script for TeamCity Build Server using Apache Tomcat
#
# description: Run TeamCity Build Server
# processname: server

PRGDIR=`dirname $0`
TEAMCITY_HOME=`cd $PRGDIR/.. ; pwd`
CATALINA_BASE=$TEAMCITY_HOME
HOSTNAME=`hostname -s`

. /etc/teamcity-server.conf

[ -f $CATALINA_HOME/bin/startup.sh ] || exit 0

export JAVA_HOME CATALINA_HOME CATALINA_BASE

[ -d $TEAMCITY_HOME/logs ] || mkdir $TEAMCITY_HOME/logs
[ -d $TEAMCITY_HOME/temp ] || mkdir $TEAMCITY_HOME/temp
[ -d $TEAMCITY_HOME/webapps ] || mkdir $TEAMCITY_HOME/webapps
[ -d $TEAMCITY_HOME/work ] || mkdir $TEAMCITY_HOME/work

case "$1" in
  start)
    echo "Starting TeamCity Build Server"

    # Use "teamcity.data.path" system property which must be set for Tomcat's VM.
    # By default it points to "${user.home}/.BuildServer" directory.
    JAVA_OPTS="-Xms768m -Xmx768m -XX:PermSize=196m -XX:MaxPermSize=196m"
    JAVA_OPTS="$JAVA_OPTS -Dteamcity"
    JAVA_OPTS="$JAVA_OPTS -Djava.net.preferIPv4Stack=true"
    JAVA_OPTS="$JAVA_OPTS -Djava.awt.headless=true"
    JAVA_OPTS="$JAVA_OPTS -Djava.rmi.server.hostname=$HOSTNAME"
    JAVA_OPTS="$JAVA_OPTS -Dteamcity.data.path=${TEAMCITY_HOME}/data"
    JAVA_OPTS="$JAVA_OPTS -Dlog4j.configuration=file:${TEAMCITY_HOME}/conf/teamcity-server-log4j.xml"
    JAVA_OPTS="$JAVA_OPTS -Dteamcity_logs=${TEAMCITY_HOME}/logs"
    JAVA_OPTS="$JAVA_OPTS -Dteamcity.diskSpaceWatcher.threshold=250000"
    JAVA_OPTS="$JAVA_OPTS -Dteamcity.queue.mergeBuilds=true"
    JAVA_OPTS="$JAVA_OPTS -Dmodification.check.interval=360"
    export JAVA_OPTS
    $CATALINA_HOME/bin/startup.sh
    echo
    ;;

  stop)
    echo "Shutting down TeamCity Build Server"
    $CATALINA_HOME/bin/shutdown.sh
    echo
    ;;

  *)
    echo "Usage: `basename $0` {start|stop}"
    exit 1
esac

exit 0
