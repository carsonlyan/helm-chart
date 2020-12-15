#!/bin/bash

imageTag=0.1.2-172cd576 
vtdScaleFolder=/home/appuser/vtd-scale/helm

echo 'upgrade scale'
sudo -i
cd $vtdScaleFolder
helm -n default upgrade scale . --set imageTag=$imageTag

echo 'upgrade scale complete'
exit
