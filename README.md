# TeamCity Vagrant

This is a Vagrant setup for creating a TeamCity server. It uses a shell script for provisioning.

## Requirements

You'll need to have the following tools installed

* [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
* [Vagrant](http://vagrantup.com/)

The following should be downloaded and copied to the files directory.

* [JDK 6](http://www.oracle.com/technetwork/java/javasebusiness/downloads/java-archive-downloads-javase6-419409.html)
* [Apache Tomcat](http://tomcat.apache.org/download-60.cgi)
* [TeamCity](http://www.jetbrains.com/teamcity/download/index.html)
* [MySQL JDBC Driver](http://dev.mysql.com/downloads/connector/j)

The shell scripts expect to find a 32 bit JDK 6u45, Tomcat version 6.0.36 zip file, TeamCity version 8.0.2 war and
the MySQL JDBC Driver 5.1.25 file in the files directory.

## Starting the TeamCity server

To create the TeamCity server VM and start the server run

    $ vagrant up teamcity
