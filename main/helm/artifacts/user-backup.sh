#!/bin/bash

echo 'ensure hdfs is running'
until hadoop fs -ls /
do
   echo 'hadoop not ready.  sleep and try again'
   sleep 1
done

echo 'prepare hdfs'
hadoop fs -mkdir -p /user/root/.userbackup/
hadoop fs -chmod 777 /user

echo 'send user data to hdfs'
hadoop fs -put -f /etc/passwd /etc/shadow /etc/group /user/root/.userbackup/
