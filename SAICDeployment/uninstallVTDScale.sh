#!/bin/bash

clearPVC(){
  for pvc in `kubectl get pvc -o name -n vtd`; do
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
helm  -n vtd uninstall scale && kubectl -n vtd delete ${source} --all --grace-period=0 --force
exitCode=$?
if [[ $1 == "pvc" ]];then
  clearPVC
fi
exit ${exitCode}
