#!/bin/bash

clearPVC(){
  for pvc in `kubectl get pvc -o name`; do
    name=${pvc#*/}
    if [[ "$name" != "my-release-keycloak" ]]; then
      kubectl delete pvc $name
    fi
  done
  if [[ $? == 0 ]];then
    kubectl delete pv --all
  fi
}

source="statefulsets,daemonsets,replicasets,services,deployments,pods,rc,ingresses,configmaps"
sudo -i && helm  -n default uninstall scale && kubectl -n default delete ${source} --all --grace-period=0 --force
exitCode=$?
if [[ $1 == "pvc" ]];then
  clearPVC
fi
exit ${exitCode}