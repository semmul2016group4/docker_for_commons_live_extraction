FROM debian:jessie
MAINTAINER Magnus Knuth <magnus.knuth@hpi.de>

RUN apt-get update
RUN apt-get upgrade -y

# Set timezone explicitely
RUN echo "Etc/UTC" > /etc/timezone 
RUN dpkg-reconfigure -f noninteractive tzdata

# Install java
RUN apt-get install -y default-jdk

# Setup Extraction Framework
# -- Install maven
RUN apt-get install -y maven
# -- Install git
RUN apt-get install -y git
# -- create & change to  projectdirectory
RUN mkdir /extractionframework && cd /extractionframework
# -- clone repository
RUN git clone -b commons-test https://github.com/semmul2016group4/extraction-framework.git
# -- change to project root and run maven
RUN cd extraction-framework && mvn clean install
# -- create empty pw.txt
RUN cd extraction-framework/live && touch pw.txt
# -- copy lastPublishedFile.txt
ADD lastPublishedFile.txt extraction-framework/live/tmp/
# -- Rename files for commons
# ---- Rename live.ini
RUN mv extraction-framework/live/common_config.ini extraction-framework/live/live.ini
# ---- Rename live.xml
RUN mv extraction-framework/live/common_config.xml extraction-framework/live/live.xml

# Copy file for execution
ADD run.sh .
# -- make file executable
RUN chmod +x ./run.sh

# Expose mysql port
EXPOSE 3306

# Install & Configure mysql
# setup config for mysql DB
RUN echo mysql-server mysql-server/root_password password root | debconf-set-selections
RUN echo mysql-server mysql-server/root_password_again password root | debconf-set-selections
# -- Install Client and Server
RUN apt-get install -q -y mysql-server mysql-client
# -- Start mysql
RUN service mysql start && sleep 30s && mysql --protocol=tcp -u root -proot -e "CREATE DATABASE dbpedia_live_cache"
# ---- Copy SQL file to Container
ADD dbstructure.sql .
# ---- Load SQL file into DB
RUN service mysql start && sleep 30s && mysql -uroot -proot dbpedia_live_cache < dbstructure.sql && mysql -uroot -proot dbpedia_live_cache < extraction-framework/live/src/main/SQL/createTableRCStatistics.sql
# ---- Create backup of database datadir
RUN mkdir mysqlbackup && cp -a /var/lib/mysql/. /mysqlbackup

# Execute MYSQL and live extraction framework
CMD ./run.sh
