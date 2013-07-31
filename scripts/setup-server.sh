#!/bin/sh

NTP_SERVER=time.euro.apple.com

MYSQL_PASSWORD=admin

JDK=jdk1.6.0_45
TOMCAT=apache-tomcat-6.0.36

TEAMCITY_DB_NAME=teamcity
TEAMCITY_DB_USER=teamcity
TEAMCITY_DB_PASS=teamcity

TEAMCITY_DIR=/opt/teamcity-server
TEAMCITY_USER=teamcity
TEAMCITY_GROUP=teamcity
TEAMCITY_WAR=TeamCity-8.0.2.war

# Install various packages required to run TeamCity
apt-get update -y
#apt-get upgrade -y
apt-get install -y -q ntp
apt-get install -y -q unzip

# Configure ntp server
sudo /etc/init.d/ntp stop
sed -e "s/^server.*$/server $NTP_SERVER/" < /etc/ntp.conf > /tmp/ntp.conf && sudo mv /tmp/ntp.conf /etc/ntp.conf
sudo /etc/init.d/ntp start

# Install MySQL
echo mysql-server-5.5 mysql-server/root_password password $MYSQL_PASSWORD | debconf-set-selections
echo mysql-server-5.5 mysql-server/root_password_again password $MYSQL_PASSWORD | debconf-set-selections
apt-get install -y -q mysql-server
apt-get clean

# Create database
mysql -u root -p$MYSQL_PASSWORD -e 'show databases;'| grep teamcity > /dev/null
if [ "$?" = "1" ]; then
    cat > /tmp/database-setup.sql <<EOF
CREATE DATABASE $TEAMCITY_DB_NAME DEFAULT CHARACTER SET utf8;

CREATE USER '$TEAMCITY_DB_USER'@'%' IDENTIFIED BY '$TEAMCITY_DB_PASS';
GRANT ALL ON $TEAMCITY_DB_NAME.* TO '$TEAMCITY_DB_USER'@'%';

DROP USER ''@'localhost';
DROP USER ''@'teamcity.localdomain';
EOF
# flush privileges;
    mysql -u root -p$MYSQL_PASSWORD < /tmp/database-setup.sql
fi

# Install Java and Tomcat
mkdir -p /opt
cd /opt
if [ ! -d /opt/$JDK ]; then
    sh /vagrant/files/jdk-6u45-linux-i586.bin -noregister > /dev/null
fi
if [ ! -d /opt/$TOMCAT ]; then
    unzip -q /vagrant/files/$TOMCAT.zip
    chmod +x /opt/$TOMCAT/bin/*.sh
fi

# Setup a user to run the TeamCity server
/usr/sbin/groupadd -r $TEAMCITY_GROUP 2>/dev/null
/usr/sbin/useradd -c $TEAMCITY_USER -r -s /bin/bash -d $TEAMCITY_DIR -g $TEAMCITY_GROUP $TEAMCITY_USER 2>/dev/null

if [ ! -f /etc/teamcity-server.conf ]; then
cat > /etc/teamcity-server.conf <<EOF
JAVA_HOME=/opt/$JDK
CATALINA_HOME=/opt/$TOMCAT
EOF
fi

# Copy start/stop script and Tomcat configuration files
mkdir -p $TEAMCITY_DIR/conf
cp /opt/$TOMCAT/conf/* $TEAMCITY_DIR/conf
cp -r /vagrant/files/server/* $TEAMCITY_DIR
sed -e "s/^shared.loader=.*$/shared.loader=\${catalina.base}\/shared\/lib\/*.jar/" < /opt/$TOMCAT/conf/catalina.properties > $TEAMCITY_DIR/conf/catalina.properties

mkdir -p $TEAMCITY_DIR/data/config
sed -e "s/^connectionUrl=.*$/connectionUrl=jdbc:mysql:\/\/localhost:3306\/$TEAMCITY_DB_NAME/" \
    -e "s/^connectionProperties.user=.*$/connectionProperties.user=$TEAMCITY_DB_USER/" \
    -e "s/^connectionProperties.password=.*$/connectionProperties.password=$TEAMCITY_DB_PASS/" \
    < /vagrant/files/database.mysql.properties.dist > $TEAMCITY_DIR/data/config/database.properties

# Install TeamCity war file
if [ ! -f $TEAMCITY_DIR/$TEAMCITY_WAR ]; then
    cp /vagrant/files/$TEAMCITY_WAR $TEAMCITY_DIR
    mkdir -p $TEAMCITY_DIR/conf/Catalina/localhost
    cat > $TEAMCITY_DIR/conf/Catalina/localhost/teamcity.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<Context docBase="\${catalina.base}/$TEAMCITY_WAR">
</Context>
EOF
fi

# Install MySQL JDBC driver
if [ ! -d $TEAMCITY_DIR/shared/lib ]; then
    mkdir -p $TEAMCITY_DIR/shared/lib
    cp /vagrant/files/mysql-connector-java-5.1.25-bin.jar $TEAMCITY_DIR/shared/lib
fi
mkdir $TEAMCITY_DIR/logs

chown -R $TEAMCITY_USER:$TEAMCITY_GROUP $TEAMCITY_DIR

# Install init script to start TeamCity on server boot
if [ ! -f /etc/init.d/teamcity-server ]; then
    cp /vagrant/files/server/bin/teamcity-server /etc/init.d
    update-rc.d teamcity-server defaults
fi

/etc/init.d/teamcity-server start
