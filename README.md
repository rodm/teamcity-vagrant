# TeamCity Vagrant

This is a Vagrant setup for creating a TeamCity server and build agents. It uses a shell script for provisioning.

## Requirements

You'll need to have the following tools installed

* [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
* [Vagrant](http://vagrantup.com/)

The following should be downloaded and copied to the files directory.

* [JDK 7](http://www.oracle.com/technetwork/java/javase/downloads/index.html)

The shell scripts expect to find a 64 bit JDK version 7u45 installer in the files directory. The Apache Tomcat zip,
TeamCity war file and MySQL JDBC driver are downloaded by the scripts, if needed, and saved to the files directory.

By default Ubuntu 12.04 VMs are used, the Vagrantfile can be modified to use CentOS 6.4 VM by commenting out the
box and box_url properties for precise64 and uncommenting the centos64 values.

## Starting the TeamCity server

To create the TeamCity server VM and start the server run, the first run may take about 10 minutes

    $ vagrant up teamcity

To create and start a TeamCity build agent run, replacing vm-name with agent01, agent02 or agent03.

    $ vagrant up [vm-name]
