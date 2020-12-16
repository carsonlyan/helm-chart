#!/bin/bash
set -e

while [[ $# -ge 1 ]]; do
	case $1 in
		-t|--tag )
			tag=$2
			shift 2
			;;
		-h|--helmDir )
			helmDir=$2
			shift 2
			;;
		-a|--applyCert )
			applyCert="true"
			shift
			;;
		-s|--setSc )
			setSc="true"
			shift
			;;
		* )
			echo "invalid argument:$1"
			shift
			;;
    esac
done

if [[ ${helmDir} == "." ]]; then
  helmDir=$(pwd)
fi

if [[ ! -d "${helmDir}" ]]; then
  echo "${helmDir} does not exist, directly exit with 1."
  exit 1
fi

if [[ -z ${tag} ]]; then
  echo "tag is empty. set with default."
  tag="latest"
fi

if [[ ${applyCert} == "true" ]];then
  echo 'apply cert-manager'
  kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v0.12.0/cert-manager.yaml
fi

if [[ ${setSc} == "true" ]];then
  echo 'Define default RWO storage class, csi-rbd-sc on SAIC-Test'
  kubectl patch storageclass csi-rbd-sc -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
fi

echo 'add helm Chart Dependencies'
cd $helmDir
helm repo add bitnami https://charts.bitnami.com/bitnami
helm dependency update

echo 'install scale using helm'
helm -n vtd install scale . --set imageTag=$tag

echo 'installation complete'
exit 0
