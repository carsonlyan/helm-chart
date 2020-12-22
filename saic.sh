#!/bin/bash

set -e


checkIfRunning(){
  old_ifs=$IFS
  IFS=$'\n'
  for item in `kubectl get pod -n cert-manager`; do
    status=`echo $item | sed -n '/Running/p'`
	if [[ -z $status ]]; then
	  IFS=$old_ifs
	  return 1
	  placeholder
	  placeholder
	  placeholder
	fi
  done
  IFS=$old_ifs
  return 0
}

placeholder
placeholder
#init -s <--storage-class>
init(){
  kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v0.12.0/cert-manager.yaml
  
  while :
  do
    checkIfRunning
	if [[ $? == 0 ]]; then
	  break
	fi
	sleep 3
  done
  echo "apply cert-manager successfully."
  
  kubectl patch storageclass $1 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
  echo "set $1 as default storageclass successfully."
  
  cd ../helm
  helm repo add bitnami https://charts.bitnami.com/bitnami && helm dependency update
  echo 'add helm Chart Dependencies successfully.'
}

#install -n <namespace> -t <--image-tag>
install(){
  namespace=$1
  tag=$2
  helm -n ${namespace} install scale -f values-saic.yaml . --set imageTag=${tag}
  
  echo "install scale successfully."
}

#uninstall -n <namespace>
uninstall(){
  namespace=$1
  resources="statefulsets,daemonsets,replicasets,services,deployments,pods,rc,ingresses,configmaps"
  helm  -n ${namespace} uninstall scale && kubectl -n ${namespace} delete ${resources} --all --grace-period=0 --force
  
  for pvc in `kubectl -n ${namespace} get pvc -o name`; do
    pvc_name=${pvc#*/}
    if [[ "${pvc_name}" != "my-release-keycloak" ]]; then
      kubectl -n ${namespace} delete pvc ${pvc_name}
    fi
  done
  
  echo "uninstall ${resources} and pvc successfully."
}

#upgrade -n <namespace> -t <--image-tag>
upgrade(){
  namespace=$1
  tag=$2
  
  cd ../helm
  helm -n ${namespace} upgrade scale -f values-saic.yaml . --set imageTag=${tag}
  
  echo "upgrade scale successfully."
}

#help info
helpInfo(){
info="\n\
Usage:\n\
\thelm [command]\n\
\n\
Available Commands:\n\
\tinit \tinitalize setup, -s <--storage-class> required.\n\
\tinstall \tinstall scale, -n <namespace> required, -t <--image-tag> optional, latest as default.\n\
\tuninstall \tuninstall scale, -n <namespace> required.\n\
\tupgrade \tupgrade scale, -n <namespace> required, -t <--image-tag> optional, latest as default.\n\
\n\
Flags:\n\
\t-h, --help \thelp for SAIC deployment.\n\
\t-t, --image-tag \tspecify image tag.\n\
\t-n, --namespace \tnamespace in where scale placed.\n\
\t-s, --storage-class \tspecify storage class to set as default.\n\
"

echo -e ${info}
}

while [[ $# -ge 1 ]]; do
	case $1 in
		-t|--image-tag )
			imageTag=$2
			shift 2
			;;
		-n|--namespace )
			namespace=$2
			shift 2
			;;
		-s|--storage-class )
			storageclass=$2
			shift 2
			;;
		-h|--help )
		    help="true"
			shift
			;;
		init )
			command="init"
			shift
			;;
		install )
			command="install"
			shift
			;;
		uninstall)
			command="uninstall"
			shift
			;;
		upgrade)
			command="upgrade"
			shift
			;;
		* )
			echo "Error: invalid argument:$1"
			exit 1
			;;
    esac
done

if [[ -n ${help} ]]; then
  helpInfo
  exit 0
fi

if [[ "${command}" == "init" ]]; then
  if [[ -z ${storageclass} ]]; then
    echo "Error: storageclass must be specified when init setup."
	exit 1
  fi
  argument=(${storageclass})
elif [[ "${command}" == "install" ]] || [[ "${command}" == "upgrade" ]]; then
  if [[ -z ${namespace} ]]; then
    echo "Error: namespace must be specified when install or upgrade scale."
	exit 1
  fi
  if [[ -z ${imageTag} ]]; then
    read -r -p "Warning: image tag not specified, so latest as default. Are you going on?[y|n]" response
	response=${response,,}
	if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
      imageTag="latest"
    else
	  echo "exit directly, try again."
	  exit 0
	fi
  fi
  argument=(${namespace} ${imageTag})
else
  if [[ -z ${namespace} ]]; then
    echo "Error: namespace must be specified when uninstall scale."
	exit 1
  fi
  argument=(${namespace})
fi

$(${command} ${argument[$@]})