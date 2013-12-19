#!/bin/sh

NTP_SERVER=time.euro.apple.com

JDK=jdk1.7.0_45
JDK_FILE=jdk-7u45-linux-i586.tar.gz

TEAMCITY_DIR=/opt/teamcity-agent
TEAMCITY_USER=teamcity
TEAMCITY_GROUP=teamcity

# Install various packages required to run a TeamCity Build Agent
apt-get update -y
apt-get install -y -q ntp
apt-get install -y -q unzip
apt-get install -y -q xvfb
apt-get install -y -q libxtst6
apt-get install -y -q libxi6
apt-get install -y -q libxrender1
apt-get install -y -q libfontconfig1

# Reconfigure /etc/ntp.conf to use server
sudo /etc/init.d/ntp stop
sed -e "s/^server.*$/server $NTP_SERVER/g" < /etc/ntp.conf > /tmp/ntp.conf && sudo mv /tmp/ntp.conf /etc/ntp.conf
sudo /etc/init.d/ntp start

# Setup a user to run the TeamCity agent
/usr/sbin/groupadd -r $TEAMCITY_GROUP 2>/dev/null
/usr/sbin/useradd -c $TEAMCITY_USER -r -s /bin/bash -d $TEAMCITY_DIR -g $TEAMCITY_GROUP $TEAMCITY_USER 2>/dev/null

cat >> /etc/hosts <<EOF
192.168.80.10   teamcity.localdomain teamcity
EOF

# Install Java
mkdir -p /opt
if [ ! -d /opt/$JDK ]; then
    tar -xzf /vagrant/files/$JDK_FILE -C /opt
fi

# Copy start/stop script
cp -r /vagrant/files/agent $TEAMCITY_DIR

# Download Build Agent from server and install
wget -q --no-proxy http://teamcity:8111/teamcity/update/buildAgent.zip -O /tmp/buildAgent.zip
mkdir -p $TEAMCITY_DIR/agent
unzip -q /tmp/buildAgent.zip -d $TEAMCITY_DIR/agent
chmod ug+x $TEAMCITY_DIR/agent/bin/agent.sh

# Create agent conf and properties files
if [ ! -f /etc/teamcity-agent.conf ]; then
    cat > /etc/teamcity-agent.conf <<EOF
JAVA_HOME=/opt/$JDK
EOF
fi

AGENT_NAME=`hostname -s`
sed -e "s/^name=.*$/name=$AGENT_NAME/g" \
    -e "s/^serverUrl=.*$/serverUrl=http:\/\/teamcity:8111\/teamcity/g" \
     < $TEAMCITY_DIR/agent/conf/buildAgent.dist.properties > /etc/teamcity-agent.properties

mkdir $TEAMCITY_DIR/logs

chown -R $TEAMCITY_USER:$TEAMCITY_GROUP $TEAMCITY_DIR

# Install init script to start TeamCity on server boot
if [ ! -f /etc/init.d/teamcity-agent ]; then
    cp /vagrant/files/agent/bin/teamcity-agent /etc/init.d
    update-rc.d teamcity-agent defaults
fi

/etc/init.d/teamcity-agent start
