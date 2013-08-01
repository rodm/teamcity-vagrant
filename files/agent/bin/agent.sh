#!/bin/sh
#
# Startup script for TeamCity Build Agent
#
# description: Run TeamCity Build Agent
# processname: agent

PRGDIR=`dirname $0`
TEAMCITY_HOME=`cd $PRGDIR/.. ; pwd`
HOSTNAME=`hostname -s`

AGENT_DIR=$TEAMCITY_HOME/agent
CONFIG_FILE=/etc/teamcity-agent.properties

if [ ! -f /etc/teamcity-agent.conf ]; then
    echo "No configuration file found."
    exit 1
fi
. /etc/teamcity-agent.conf

if [ ! -f $CONFIG_FILE ]; then
    echo "No build agent properties file found."
    exit 1
fi

JAVA_OPTS=-Dteamcity-agent
TZ=Europe/London

export JAVA_HOME JAVA_OPTS
export CONFIG_FILE TZ

cd $AGENT_DIR/bin
exec ./agent.sh $*
