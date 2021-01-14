# VTD Scale Installation on SAIC Cluster

## 1. Validate environment

Assume there is the strictest network limitation and security control on the client cluster, please check the tools/version/internet connections, including
- Kubernetes version >= v1.17.9 expected
- Docker version >= 18.03 expected
- Tools:
     - Helm V3 (ONLY available via admin privilege on SAIC-Test)
     - Git V2.x. Please use git / GitHub to transfer files to the clustering environment, for example, 
        - Copy the helm/sh files to cluster nodes via git,  https://dev.azure.com/MSC-Devops/MLG/_git/scale-modules?path=%2Fscale%2Fsrc%2Fmain
		- Copy test data into cluster via Github
- Check access to external registry
     -  docker hub - docker.io / hub.docker.com
     -  git hub - https://github.com/
     -  docker.elastic.co
     -  gcr.io
     -  quay.io

## 2. Installation 
### 2.1 Plan 
- What namespace? Suggest isolating from default.  Please input -n param to the shell script, default "latest". 
- Which image tag to deploy? Please input -t param to the shell script
- Plan the "node groups" and tag nodes with Core,  System, Logging and HDFS.
- Check default RWX/RWO storage class on the clustering. If not there,  request it from the vendor support team

### 2.2 Transfer images - on local environment 
Pull Docker images from hexagonmscsdc registry on Azure and then push them to registry on Ali cloud (set up by Kay).
   - execute _az login_ and _az acr login --name hexagonmscsdc_
   - Update the 'imageTag' in script file
   - execute _transferDockerImages.sh_

### 2.3 Deploy keycloak ((assuming the cluster can't access Keycloak hosted on Internet) 
- exeucute _installKeycloak.sh -n namespace_
- Create realm/client/User credential in KeyCloak via http://keycloak.local.scale-hexagon.com (account admin / admin). Suggest naming realm as VTDScale, client as gatekeeper and group as my-app. Refer to https://www.openshift.com/blog/adding-authentication-to-your-kubernetes-web-applications-with-keycloak.  
- update OpenId section in _values-saic.yaml_ as per Keycloak setup.
      > openId:
           url: http://10.135.3.9:30090/auth/realms/VTDScale  => change the IP
           clientId: gatekeeper
           clientSecret: 6754a1c3-8de5-4dfb-9c54-d047711525d8  => change the secret
           encryptionKey: vGcLt8ZUdPX5fXhtLZaPHZkGWHZrT6aa
           group: my-app

### 2.4 Deploy VTDScale (depends on 2.2 & 2.3)
- Execute _saic initSetup -s storageClass_. (On testing,  it is csi-rbd-sc).

- Update nfs ip in _values-saic.yaml_, the IP is different in environments and it must be in cluster IP range.

- execute _saic install -n namespace -t imageTag_

- **TEST Environment Only** In case Port 443 has been already used on Nginx-Ingress,  edit scale-ingress to remove HttPS/TLS config
   `$ kubectl edit ingress scale-ingress`

## 3 Test the installation
Add the following information to _/etc/hosts_, then visit http://admin.local.scale-hexagon.com/
`10.135.3.8  keycloak.local.scale-hexagon.com, admin.local.scale-hexagon.com, spark.local.scale-hexagon.com, jupyter.local.scal  e-hexagon.com, livy.local.scale-hexagon.com, logs.local.scale-hexagon.com, jenkins.local.scale-hexagon.com, superset.local. scal e-hexagon.com, gitea.local.scale-hexagon.com`
