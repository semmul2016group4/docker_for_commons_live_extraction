# Docker for Live Extraction from Wikimedia Commons

This docker files set up the dbpedia live extraction framework to extract changeset from commons.wikimedia.org.

## Components

* DBpedia extraction framework
  * Configuration files for commons.wikimedia
* MySQL DB for caching
* run.sh to start cache and extraction

## Access the Data

In order to access the data created by the extraction framework we recommend to mount the volumes for the produces triples (change-sets) and the datadirectory of the mysql cache.

Example
* MySQL datadir
  * /var/lib/mysql - datadir inside container
  * /mysql_data_dir - absolute path to directory on host
* Triples
  * /extraction-framework/live/tmp - directory inside container
  * /change_sets - absolute path to directory on host

´´´
docker run \
  -v /mysql_data_dir:/var/lib/mysql \
  -v /change_sets:/extraction-framework/live/tmp \
  <container name> <command>
´´´
