#!/bin/bash

set -e

while [[ $# -ge 1 ]]; do
	case $1 in
		-n|--namespace )
			namespace=$2
			shift 2
			;;
		* )
			echo "invalid argument:$1"
			shift
			;;
    esac
done

if [[ -z ${namespace} ]]; then
  namespace="default"
fi

keycloakFolder=./keycloak

echo 'install keycloak'
cd $keycloakFolder
kubectl apply -f pvc.yaml -n $namespace
kubectl apply -f keycloak.yaml -n $namespace

echo 'installation complete'


