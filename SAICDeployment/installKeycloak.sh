#!/bin/bash

keycloakFolder=/home/appuser/vtd-scale/keycloak


echo 'install keycloak'
cd $keycloakFolder
kubectl apply -f pvc.yaml -n vtd
kubectl apply -f keycloak.yaml -n vtd

echo 'installation complete'


