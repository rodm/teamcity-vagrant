#!/bin/sh

NTP_SERVER=time.euro.apple.com

JDK=jdk1.8.0_92
JDK_FILE=jdk-8u92-linux-x64.tar.gz

TOMCAT_VERS=7.0.57
TOMCAT=apache-tomcat-${TOMCAT_VERS}
TOMCAT_DIR=/opt/$TOMCAT
TOMCAT_URL=http://search.maven.org/remotecontent?filepath=org/apache/tomcat/tomcat/${TOMCAT_VERS}/tomcat-${TOMCAT_VERS}.zip

MYSQL_JDBC_VERS=5.1.34
MYSQL_JDBC_JAR=mysql-connector-java-${MYSQL_JDBC_VERS}.jar
MYSQL_JDBC_URL=http://search.maven.org/remotecontent?filepath=mysql/mysql-connector-java/${MYSQL_JDBC_VERS}/${MYSQL_JDBC_JAR}
MYSQL_PASSWORD=admin

TEAMCITY_DB_NAME=teamcity
TEAMCITY_DB_USER=teamcity
TEAMCITY_DB_PASS=teamcity

TEAMCITY_DIR=/opt/teamcity-server
TEAMCITY_WAR=TeamCity-9.1.7.war
TEAMCITY_URL=http://download.jetbrains.com/teamcity/$TEAMCITY_WAR
TEAMCITY_USER=teamcity
TEAMCITY_GROUP=teamcity

# Install various packages required to run TeamCity
if [ -f /etc/redhat-release ]; then
    yum -y install ntp
else
    apt-get update -y
    apt-get install -y -q ntp
    apt-get install -y -q unzip
fi

# Configure ntp server
sudo /etc/init.d/ntp stop
sed -e "s/^server.*$/server $NTP_SERVER/" < /etc/ntp.conf > /tmp/ntp.conf && sudo mv /tmp/ntp.conf /etc/ntp.conf
sudo /etc/init.d/ntp start

# Configure MySQL for TeamCity
# https://confluence.jetbrains.com/display/TCD9/How+To...#HowTo...-ConfigureNewlyInstalledMySQLServer
mkdir -p /etc/mysql/conf.d
cp /vagrant/files/mysql/teamcity.cnf /etc/mysql/conf.d

# Install MySQL
if [ -f /etc/redhat-release ]; then
    yum -y install mysql-server
    /sbin/service mysqld start
    /usr/bin/mysqladmin -u root password "$MYSQL_PASSWORD"
else
    echo mysql-server-5.5 mysql-server/root_password password $MYSQL_PASSWORD | debconf-set-selections
    echo mysql-server-5.5 mysql-server/root_password_again password $MYSQL_PASSWORD | debconf-set-selections
    apt-get install -y -q mysql-server
    apt-get clean
fi

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
if [ ! -d /opt/$JDK ]; then
    tar -xzf /vagrant/files/$JDK_FILE -C /opt
fi
if [ ! -d $TOMCAT_DIR ]; then
    if [ ! -f /vagrant/files/$TOMCAT.zip ]; then
        wget -q --no-proxy $TOMCAT_URL -O /vagrant/files/$TOMCAT.zip
    fi
    unzip -q /vagrant/files/$TOMCAT.zip -d /opt
    chmod +x $TOMCAT_DIR/bin/*.sh
fi

# Setup a user to run the TeamCity server
/usr/sbin/groupadd -r $TEAMCITY_GROUP 2>/dev/null
/usr/sbin/useradd -c $TEAMCITY_USER -r -s /bin/bash -d $TEAMCITY_DIR -g $TEAMCITY_GROUP $TEAMCITY_USER 2>/dev/null

if [ ! -f /etc/teamcity-server.conf ]; then
cat > /etc/teamcity-server.conf <<EOF
JAVA_HOME=/opt/$JDK
CATALINA_HOME=$TOMCAT_DIR
EOF
fi

# Copy start/stop script and Tomcat configuration files
mkdir -p $TEAMCITY_DIR/conf
cp $TOMCAT_DIR/conf/* $TEAMCITY_DIR/conf
cp -r /vagrant/files/server/* $TEAMCITY_DIR

mkdir -p $TEAMCITY_DIR/data/config
sed -e "s/^connectionUrl=.*$/connectionUrl=jdbc:mysql:\/\/localhost:3306\/$TEAMCITY_DB_NAME/" \
    -e "s/^connectionProperties.user=.*$/connectionProperties.user=$TEAMCITY_DB_USER/" \
    -e "s/^connectionProperties.password=.*$/connectionProperties.password=$TEAMCITY_DB_PASS/" \
    < /vagrant/files/database.mysql.properties.dist > $TEAMCITY_DIR/data/config/database.properties

# Install TeamCity war file
if [ ! -f $TEAMCITY_DIR/$TEAMCITY_WAR ]; then
    if [ ! -f /vagrant/files/$TEAMCITY_WAR ]; then
        wget -q --no-proxy $TEAMCITY_URL -P /vagrant/files
    fi
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
    mkdir -p $TEAMCITY_DIR/data/lib/jdbc
    if [ ! -f /vagrant/files/$MYSQL_JDBC_JAR ]; then
        wget -q --no-proxy $MYSQL_JDBC_URL -O /vagrant/files/$MYSQL_JDBC_JAR
    fi
    cp /vagrant/files/$MYSQL_JDBC_JAR $TEAMCITY_DIR/data/lib/jdbc
fi
mkdir $TEAMCITY_DIR/logs

chown -R $TEAMCITY_USER:$TEAMCITY_GROUP $TEAMCITY_DIR

if [ -f /etc/redhat-release ]; then
    # Allow connections
    iptables -I INPUT 5 -p tcp --dport 8111 -j ACCEPT
    iptables --line-numbers -L INPUT -n
    /sbin/service iptables save
fi

# Install init script to start TeamCity on server boot
if [ -f /etc/redhat-release ]; then
    if [ ! -f /etc/rc.d/init.d/teamcity-server ]; then
        cp /vagrant/files/server/bin/teamcity-server /etc/rc.d/init.d
        sudo chkconfig --add teamcity-server
    fi
    /sbin/service teamcity-server start
else
    if [ ! -f /etc/init.d/teamcity-server ]; then
        cp /vagrant/files/server/bin/teamcity-server /etc/init.d
        update-rc.d teamcity-server defaults
    fi
    /etc/init.d/teamcity-server start
fi
