# VTD Scale Installation on SAIC Cluster

## 1. Validate environment

Assume there is the strictest network limitation and security control on the client cluster, please check the tools/version/internet connections, including
- Kubernetes version >= v1.17.9 expected
- Docker version >= 18.03 expected
- Tools:
     - Helm V3 (sudo -i, ONLY available via admin privilege on SAIC-Test)
     - Git V2.x
- Check access to external registry
     -  docker hub - docker.io / hub.docker.com
     -  git hub - https://github.com/
     -  docker.elastic.co
     -  gcr.io
     -  quay.io

## 2. Preparation 
<u>Determine the image tag to be released</u>

<u>On local environment:</u>
Pull images from hexagonmscsdc on Azure container registry and push them to Ali cloud. 
   - execute _az login_ and _az acr login --name hexagonmscsdc_
   - Update the 'imageTag' in script file
   - execute _transferDockerImages.sh_

<u>On Clustering environment:</u>
1. Plan the "node groups" and tag machines with Core,  System, Logging and HDFS.
2. Request Ceph info for RWX/RWO storage class from the vendor support team, then update default RWO storage class in _installKeycloak.sh_(On testing,  it is csi-rbd-sc).    

3. Update image tag in _values-saic.yaml_, _installKeycloak.sh_ (which one is better?????)

4. Update nfs ip in _value-saic.yaml_, the IP is different in environments and it must be in cluster IP range.

5. Deploy Keycloak (assuming the cluster can't access Keycloak hosted on Internet). 
    - In Keycloak folder, exeucute _installKeycloak.sh_
    - Create realm/client/User credential in KeyCloak via http://keycloak.local.scale-hexagon.com (using account admin / admin). Suggest name realm as VTDScale, client as gatekeeper and group as my-app. Refer to https://www.openshift.com/blog/adding-authentication-to-your-kubernetes-web-applications-with-keycloak.  
    - update OpenId section in _value-saic.yaml_ as per Keycloak setup.
      > openId:
           url: http://10.135.3.9:30080/auth/realms/VTDScale  => change the IP
           clientId: gatekeeper
           clientSecret: 6754a1c3-8de5-4dfb-9c54-d047711525d8  => change the secret
           encryptionKey: vGcLt8ZUdPX5fXhtLZaPHZkGWHZrT6aa
           group: my-app

## 3. Install Procedure
1. In VTD-Scale folder, execute _installVTDScale.sh_

2. **TEST Environment Only** In case Port 443 has been already used on Nginx-Ingress,  edit scale-ingress to remove HttPS/TLS config
   `$ kubectl edit ingress scale-ingress`

## 4 Test the installation
Add the following information to _/etc/hosts_, then visit http://admin.local.scale-hexagon.com/
`10.135.3.8  keycloak.local.scale-hexagon.com, admin.local.scale-hexagon.com, spark.local.scale-hexagon.com, jupyter.local.scal  e-hexagon.com, livy.local.scale-hexagon.com, logs.local.scale-hexagon.com, jenkins.local.scale-hexagon.com, superset.local. scal e-hexagon.com, gitea.local.scale-hexagon.com`
