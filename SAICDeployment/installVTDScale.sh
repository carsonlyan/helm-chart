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
		-s|--sc )
			sc="true"
			shift
			;;
		-d|--dependency )
			dependency="true"
			shift
			;;
		* )
			echo "invalid argument:$1"
			shift
			;;
    esac
done

if [[ -z ${helmDir} ]]; then
  helmDir="/home/appuser/vtd-scale/helm"
fi

if [[ -z ${tag} ]]; then
  echo "tag is empty. set with default."
  tag="latest"
fi

if [[ ${applyCert} == "true" ]]; then
  echo 'apply cert-manager'
  kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v0.12.0/cert-manager.yaml
fi

if [[ ${sc} == "true" ]]; then
  echo 'Define default RWO storage class, csi-rbd-sc on SAIC-Test'
  kubectl patch storageclass csi-rbd-sc -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
fi

cd $helmDir
if [[ ${dependency} == "true" ]]; then
  echo 'add helm Chart Dependencies'
  helm repo add bitnami https://charts.bitnami.com/bitnami
  helm dependency update
fi

echo 'install scale using helm'
helm -n vtd install scale -f values-saic.yaml . --set imageTag=$tag

echo 'installation complete'
exit 0
