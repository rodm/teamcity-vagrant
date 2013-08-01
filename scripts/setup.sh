#!/bin/sh

HOST=`hostname -s`
if [ "$HOST" = "teamcity" ]; then
    sh -x /vagrant/scripts/setup-server.sh
else
    sh -x /vagrant/scripts/setup-agent.sh
fi
