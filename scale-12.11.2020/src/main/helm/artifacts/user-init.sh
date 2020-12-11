#!/bin/bash

cp -fv /home/admin/*.ipynb ~

if [ ! -d ~/storage ]; then
    ln -s /storage ~/storage
fi

if [ ! -d ~/hdfs ]; then
    ln -s /hdfs ~/hdfs
fi
