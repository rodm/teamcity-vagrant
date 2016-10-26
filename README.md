# TeamCity Vagrant

This is a Vagrant setup for creating a TeamCity server and build agents. It uses a shell script for provisioning.

## Requirements

1. Install in the host machine:
* [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
* [Vagrant](https://www.vagrantup.com/downloads.html)
2. Clone this repository.

The JDK, Apache Tomcat, TeamCity WAR file and MySQL JDBC driver are downloaded by the scripts and saved to the `downloads` directory.

By default Ubuntu 12.04 VMs are used for the server and agents, except agent03 which is configured to use a
CentOS 6.4 VM. The nodes array in the `Vagrantfile` can be modified to change the OS used by any of the VMs. Both the
server and agents can be run on either Ubuntu 12.04 or CentOS 6.4.

## Starting the TeamCity server

To create the TeamCity server VM and start the server, run:

    $ vagrant up teamcity

(Note: the first run may take up to 10 minutes).

To create and start a TeamCity build agent, run the following command after replacing `vm-name` with `agent01`, `agent02` or `agent03`.

    $ vagrant up [vm-name]

## Accessing the TeamCity server

Once the server is started it can be accessed at the following URL: [http://192.168.80.10:8111/teamcity](http://192.168.80.10:8111/teamcity).
See the [TeamCity Administrator's Guide](https://confluence.jetbrains.com/display/TCD9/Administrator%27s+Guide) for configuring the server.

Once one or more agents have been started they can be authorised from the Agents page in the web UI, [http://192.168.80.10:8111/teamcity/agents.html](http://192.168.80.10:8111/teamcity/agents.html).
