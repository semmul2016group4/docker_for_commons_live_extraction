#!/bin/sh
service mysql start &&\
  sleep 30s &&\
  cd extraction-framework/live &&\
  ../run live  
