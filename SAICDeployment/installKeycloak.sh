#!/bin/bash

keycloakFolder=/home/appuser/vtd-scale/keycloak


echo 'install keycloak'
cd $keycloakFolder
kubectl apply -f pvc.yaml
kubectl apply -f keycloak.yaml

echo 'installation complete'


