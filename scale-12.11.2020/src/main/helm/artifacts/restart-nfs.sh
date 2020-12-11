#!/usr/bin/env bash

$HADOOP_HOME/sbin/hadoop-daemon.sh stop nfs3 
$HADOOP_HOME/sbin/hadoop-daemon.sh start nfs3
