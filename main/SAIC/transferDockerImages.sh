#!/bin/bash

imageTag=0.1.2-172cd576


echo 'pull images from acr'
echo '1.pull scale-worker'
docker pull hexagonmscsdc.azurecr.io/mscsoftware/scale-worker:$imageTag
echo '2.pull scale-services'
docker pull hexagonmscsdc.azurecr.io/mscsoftware/scale-services:$imageTag
echo '3.pull scale-jenkins'
docker pull hexagonmscsdc.azurecr.io/mscsoftware/scale-jenkins:$imageTag
echo '4.pull scale-demodata'
docker pull hexagonmscsdc.azurecr.io/mscsoftware/scale-demodata:$imageTag
echo '5.pull scale-demodata-adams'
docker pull hexagonmscsdc.azurecr.io/mscsoftware/scale-demodata-adams:$imageTag
echo '6.pull scale-collector'
docker pull hexagonmscsdc.azurecr.io/mscsoftware/scale-collector:$imageTag
echo '7.pull scale-worker-vtd-simulator'
docker pull hexagonmscsdc.azurecr.io/mscsoftware/scale-worker-vtd-simulator:$imageTag
echo '8.pull scale-worker-vtd-sidecar'
docker pull hexagonmscsdc.azurecr.io/mscsoftware/scale-worker-vtd-sidecar:$imageTag
echo '9.pull scale-worker-vtd-processor'
docker pull hexagonmscsdc.azurecr.io/mscsoftware/scale-worker-vtd-processor:$imageTag
echo '10.pull scale-worker-sampler'
docker pull hexagonmscsdc.azurecr.io/mscsoftware/scale-worker-sampler:$imageTag
echo '11.pull scale-worker-downloader'
docker pull hexagonmscsdc.azurecr.io/mscsoftware/scale-worker-downloader:$imageTag
echo '12.pull scale-worker-applicator'
docker pull hexagonmscsdc.azurecr.io/mscsoftware/scale-worker-applicator:$imageTag
echo '13.pull scale-worker-adams'
docker pull hexagonmscsdc.azurecr.io/mscsoftware/scale-worker-adams:$imageTag
echo '14.pull scale-git'
docker pull hexagonmscsdc.azurecr.io/mscsoftware/scale-git:$imageTag
echo '15.pull scale-admin'
docker pull hexagonmscsdc.azurecr.io/mscsoftware/scale-admin:$imageTag
echo '16.pull scale-spark'
docker pull hexagonmscsdc.azurecr.io/mscsoftware/scale-spark:$imageTag


echo 'tag images'
docker tag hexagonmscsdc.azurecr.io/mscsoftware/scale-worker:$imageTag registry.cn-hangzhou.aliyuncs.com/msc-software/scale-worker:$imageTag
docker tag hexagonmscsdc.azurecr.io/mscsoftware/scale-services:$imageTag registry.cn-hangzhou.aliyuncs.com/msc-software/scale-services:$imageTag
docker tag hexagonmscsdc.azurecr.io/mscsoftware/scale-jenkins:$imageTag registry.cn-hangzhou.aliyuncs.com/msc-software/scale-jenkins:$imageTag
docker tag hexagonmscsdc.azurecr.io/mscsoftware/scale-demodata:$imageTag registry.cn-hangzhou.aliyuncs.com/msc-software/scale-demodata:$imageTag
docker tag hexagonmscsdc.azurecr.io/mscsoftware/scale-demodata-adams:$imageTag registry.cn-hangzhou.aliyuncs.com/msc-software/scale-demodata-adams:$imageTag
docker tag hexagonmscsdc.azurecr.io/mscsoftware/scale-collector:$imageTag registry.cn-hangzhou.aliyuncs.com/msc-software/scale-collector:$imageTag
docker tag hexagonmscsdc.azurecr.io/mscsoftware/scale-worker-vtd-simulator:$imageTag registry.cn-hangzhou.aliyuncs.com/msc-software/scale-worker-vtd-simulator:$imageTag
docker tag hexagonmscsdc.azurecr.io/mscsoftware/scale-worker-vtd-sidecar:$imageTag registry.cn-hangzhou.aliyuncs.com/msc-software/scale-worker-vtd-sidecar:$imageTag
docker tag hexagonmscsdc.azurecr.io/mscsoftware/scale-worker-vtd-processor:$imageTag registry.cn-hangzhou.aliyuncs.com/msc-software/scale-worker-vtd-processor:$imageTag
docker tag hexagonmscsdc.azurecr.io/mscsoftware/scale-worker-sampler:$imageTag registry.cn-hangzhou.aliyuncs.com/msc-software/scale-worker-sampler:$imageTag
docker tag hexagonmscsdc.azurecr.io/mscsoftware/scale-worker-downloader:$imageTag registry.cn-hangzhou.aliyuncs.com/msc-software/scale-worker-downloader:$imageTag
docker tag hexagonmscsdc.azurecr.io/mscsoftware/scale-worker-applicator:$imageTag registry.cn-hangzhou.aliyuncs.com/msc-software/scale-worker-applicator:$imageTag
docker tag hexagonmscsdc.azurecr.io/mscsoftware/scale-worker-adams:$imageTag registry.cn-hangzhou.aliyuncs.com/msc-software/scale-worker-adams:$imageTag
docker tag hexagonmscsdc.azurecr.io/mscsoftware/scale-git:$imageTag registry.cn-hangzhou.aliyuncs.com/msc-software/scale-git:$imageTag
docker tag hexagonmscsdc.azurecr.io/mscsoftware/scale-admin:$imageTag registry.cn-hangzhou.aliyuncs.com/msc-software/scale-admin:$imageTag
docker tag hexagonmscsdc.azurecr.io/mscsoftware/scale-spark:$imageTag registry.cn-hangzhou.aliyuncs.com/msc-software/scale-spark:$imageTag

echo 'push images to aliyun registry'
echo '1.push scale-worker'
docker push registry.cn-hangzhou.aliyuncs.com/msc-software/scale-worker:$imageTag
echo '2.push scale-services'
docker push registry.cn-hangzhou.aliyuncs.com/msc-software/scale-services:$imageTag
echo '3.push scale-jenkins'
docker push registry.cn-hangzhou.aliyuncs.com/msc-software/scale-jenkins:$imageTag
echo '4.push scale-demodata'
docker push registry.cn-hangzhou.aliyuncs.com/msc-software/scale-demodata:$imageTag
echo '5.push scale-demodata-adams'
docker push registry.cn-hangzhou.aliyuncs.com/msc-software/scale-demodata-adams:$imageTag
echo '6.push scale-collector'
docker push registry.cn-hangzhou.aliyuncs.com/msc-software/scale-collector:$imageTag
echo '7.push scale-worker-vtd-simulator'
docker push registry.cn-hangzhou.aliyuncs.com/msc-software/scale-worker-vtd-simulator:$imageTag
echo '8.push scale-worker-vtd-sidecar'
docker push registry.cn-hangzhou.aliyuncs.com/msc-software/scale-worker-vtd-sidecar:$imageTag
echo '9.push scale-worker-vtd-processor'
docker push registry.cn-hangzhou.aliyuncs.com/msc-software/scale-worker-vtd-processor:$imageTag
echo '10.push scale-worker-sampler'
docker push registry.cn-hangzhou.aliyuncs.com/msc-software/scale-worker-sampler:$imageTag
echo '11.push scale-worker-downloader'
docker push registry.cn-hangzhou.aliyuncs.com/msc-software/scale-worker-downloader:$imageTag
echo '12.push scale-worker-applicator'
docker push registry.cn-hangzhou.aliyuncs.com/msc-software/scale-worker-applicator:$imageTag
echo '13.push scale-worker-adams'
docker push registry.cn-hangzhou.aliyuncs.com/msc-software/scale-worker-adams:$imageTag
echo '14.push scale-git'
docker push registry.cn-hangzhou.aliyuncs.com/msc-software/scale-git:$imageTag
echo '15.push scale-admin'
docker push registry.cn-hangzhou.aliyuncs.com/msc-software/scale-admin:$imageTag
echo '16.push scale-spark'
docker push registry.cn-hangzhou.aliyuncs.com/msc-software/scale-spark:$imageTag

echo 'Done!'
