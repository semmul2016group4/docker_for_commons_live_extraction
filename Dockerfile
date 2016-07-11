FROM debian:jessie
MAINTAINER Magnus Knuth <magnus.knuth@hpi.de>


#####################################
# General system setup.
#####################################

# Update installed software
RUN apt-get update
RUN apt-get upgrade -y

# Set timezone explicitely
RUN echo "Etc/UTC" > /etc/timezone 
RUN dpkg-reconfigure -f noninteractive tzdata


#####################################
# Install Java.
#####################################

# Install default JDK
RUN apt-get install -y default-jdk


#####################################
# Setup Extraction Framework
#####################################

# Install Apache maven
RUN apt-get install -y maven

# Install git
RUN apt-get install -y git

# Clone repository
RUN git clone -b commons-test https://github.com/semmul2016group4/extraction-framework.git

# Change current directory to project root
WORKDIR extraction-framework

# Install all project dependencies with maven
RUN mvn clean install

# Change current directory to live module
WORKDIR live

# Create empty pw.txt
RUN touch pw.txt

# Create output directory
RUN mkdir tmp

# Rename files for commons
# -- Rename live.ini
RUN mv common_config.ini live.ini
# -- Rename live.xml
RUN mv common_config.xml live.xml


#####################################
# Install & Configure mysql
#####################################

# setup config for mysql DB
RUN echo mysql-server mysql-server/root_password password root | debconf-set-selections
RUN echo mysql-server mysql-server/root_password_again password root | debconf-set-selections

# Install Client and Server
RUN apt-get install -q -y mysql-server mysql-client

# Start mysql and create database
RUN service mysql start && sleep 30s && mysql --protocol=tcp -u root -proot -e "CREATE DATABASE dbpedia_live_cache"

# Add SQL file to Container
ADD dbstructure.sql .

# Create tables
RUN service mysql start && sleep 30s && mysql -uroot -proot dbpedia_live_cache < dbstructure.sql && mysql -uroot -proot dbpedia_live_cache < src/main/SQL/createTableRCStatistics.sql

# Backup database datadir
RUN mkdir mysqlbackup && cp -a /var/lib/mysql/. /mysqlbackup

# Add file for execution and make it executable
ADD run.sh /
RUN chmod +x /run.sh

# Expose mysql port
EXPOSE 3306

# Execute mysql and live extraction framework
CMD ["/run.sh"]
