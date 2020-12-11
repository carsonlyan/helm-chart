#!/bin/bash

: ${HADOOP_HOME:=/usr/local/hadoop}
: ${SPARK_HOME:=/usr/local/spark}

. $HADOOP_HOME/etc/hadoop/hadoop-env.sh

# Directory to find config artifacts
CONFIG_DIR="/tmp/hadoop-config"
LOG_DIR=${HADOOP_HOME}/logs

# Copy config files from volume mount

for f in slaves core-site.xml hdfs-site.xml mapred-site.xml yarn-site.xml; do
  if [[ -e ${CONFIG_DIR}/$f ]]; then
    cp ${CONFIG_DIR}/$f $HADOOP_HOME/etc/hadoop/$f
  else
    echo "ERROR: Could not find $f in $CONFIG_DIR"
    exit 1
  fi
done


ln -s /tmp/hadoop-config/spark-defaults.conf /usr/local/spark/conf/spark-defaults.conf
ln -s /tmp/hadoop-config/hive-site.xml /usr/local/spark/conf/hive-site.xml

# Prepare Scale logging
touch /tmp/scale.log
chmod 777 /tmp/scale.log

# installing libraries if any - (resource urls added comma separated to the ACP system variable)
cd $HADOOP_HOME/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

if [[ "${HOSTNAME}" =~ "hdfs-nn" ]]; then
  sed -i s/hdfs-nn/`hostname`/ /usr/local/hadoop/etc/hadoop/core-site.xml

  if [[ ! -d /root/hdfs/namenode/current ]]; then
    echo 'format hdfs'
    mkdir -p /root/hdfs/namenode
    $HADOOP_HOME/bin/hdfs namenode -format -force -nonInteractive  
  fi

  echo 'start namenode service'
  mkdir -p /usr/local/hadoop/logs
  $HADOOP_HOME/sbin/hadoop-daemon.sh start namenode

  # count=0 && while [[ $count -lt 15 && -z `curl -sf http://hdfs-nn:50070` ]]; do echo "Waiting for http://hdfs-nn:50070" ; ((count=count+1)) ; sleep 2; done
  # [[ $count -eq 15 ]] && echo "Timeout waiting for hdfs-nn, exiting." && exit 1

  $HADOOP_HOME/bin/hadoop fs -chmod 777 /

  echo 'Start nfs services'
  $HADOOP_HOME/sbin/hadoop-daemon.sh start portmap
  $HADOOP_HOME/sbin/hadoop-daemon.sh start nfs3

  echo 'Copy restart-nfs script'
  cp ${CONFIG_DIR}/restart-nfs.sh $HADOOP_HOME/bin/restart-nfs.sh
  chmod +x $HADOOP_HOME/bin/restart-nfs.sh

  echo 'Run user sync script'
  cp ${CONFIG_DIR}/user-sync.sh /root
  chmod ugo+rx /root/*.sh
  /root/user-sync.sh &
fi

if [[ "${BOOTSTRAP}" =~ "hdfs-dn" ]]; then
  mkdir -p /root/hdfs/datanode
  #  wait up to 30 seconds for namenode
  count=0 && while [[ $count -lt 15 && -z `curl -sf http://hdfs-nn:50070` ]]; do echo "Waiting for http://hdfs-nn:50070" ; ((count=count+1)) ; sleep 2; done
  [[ $count -eq 15 ]] && echo "Timeout waiting for hdfs-nn, exiting." && exit 1
  $HADOOP_HOME/sbin/hadoop-daemon.sh start datanode
fi

if [[ "${HOSTNAME}" =~ "yarn-rm" ]]; then
  sed -i s/yarn-rm/0.0.0.0/ $HADOOP_HOME/etc/hadoop/yarn-site.xml
  cp ${CONFIG_DIR}/start-yarn-rm.sh $HADOOP_HOME/sbin/
  cd $HADOOP_HOME/sbin
  chmod +x start-yarn-rm.sh
  ./start-yarn-rm.sh
fi

if [[ "${HOSTNAME}" =~ "jupyter" ]]; then
  if [[ "${BOOTSTRAP}" =~ "jupyter-init" ]]; then
    # populate/update persistent volume
    echo 'Populating home directories'
    cp -frp /tmp/home.bak/* /home-init

    rm -fr /home-init/adimin/selftest
    cp -frp /tmp/selftest /home-init/admin
    chown -R admin:admin /home-init/admin

    echo 'Copy user management scripts'
    mkdir -p /home-init/root
    cp ${CONFIG_DIR}/user-backup.sh ${CONFIG_DIR}/user-init.sh ${CONFIG_DIR}/user-init-etc.sh /home-init/root
    chmod ugo+rx /home-init/root/*.sh

    echo 'Initialize /etc'
    /home-init/root/user-init-etc.sh

    /home-init/root/user-backup.sh

    if [[ ! -d /storage/user ]]; then
      echo 'Preparing /storage directory'
      mkdir -p /storage/user
      chmod 777 /storage/user
    fi

    # HDFS-14555 HDFS NFS gateway read Input/output error
    # cp -frupvL /home-init/admin/data/* /hdfs # tends to corrupt the NFS gateway

    if $(hadoop fs -test -f /ADAMS_COPY_IN_PROGRESS) || [ /home-init/admin/data/adams/demodata -nt /hdfs/adams/demodata ]; then
      echo 'Updating adams data'
      chown -R worker:worker /home-init/admin/data/adams

      hadoop fs -rm -r /adams
      hadoop fs -touchz /ADAMS_COPY_IN_PROGRESS
      hadoop fs -put -f -p -d /home-init/admin/data/adams / 
      hadoop fs -chown -R worker:worker /adams
      hadoop fs -rm /ADAMS_COPY_IN_PROGRESS
    else
      echo 'Adams data is up-to-date'
    fi

    if $(hadoop fs -test -f /VTD_COPY_IN_PROGRESS) || [ /home-init/admin/data/vtd/demodata -nt /hdfs/vtd/demodata ]; then
      echo 'Updating VTD data'
      chown -R worker:worker /home-init/admin/data/vtd

      hadoop fs -rm -r /vtd
      hadoop fs -rm -f /VTD_COPY_IN_PROGRESS
      hadoop fs -touchz /VTD_COPY_IN_PROGRESS
      hadoop fs -put -f -p -d /home-init/admin/data/vtd / 
      hadoop fs -chown -R worker:worker /vtd
      hadoop fs -rm /VTD_COPY_IN_PROGRESS
    else
      echo 'VTD data is up-to-date'    
    fi
  else
    echo 'Starting sftp'
    cat ${CONFIG_DIR}/sftp.config >> /etc/ssh/sshd_config
    service ssh start
    
    echo 'Startup Jupyter'
    mkdir /usr/local/jupyter
    cd /usr/local/jupyter
    cp ${CONFIG_DIR}/jupyterhub_config.py jupyterhub_config.py
    jupyterhub
  fi
fi

if [[ "${HOSTNAME}" =~ "livy" ]]; then
  if [[ "${HDFS_DISABLED}" =~ "true" ]]; then
    rm /usr/local/spark/conf/spark-defaults.conf
    ln -s /tmp/hadoop-config/spark-defaults-nohdfs.conf /usr/local/spark/conf/spark-defaults.conf
    unset HADOOP_HOME
    unset HADOOP_COMMON_HOME
    unset HADOOP_HDFS_HOME
    unset HADOOP_YARN_HOME
    unset HADOOP_MAPRED_HOME
    unset HADOOP_CONF_DIR
    unset HADOOP_VERSION

    spark
  fi

  cp ${CONFIG_DIR}/livy.conf /usr/local/livy/conf/
  mkdir /usr/local/apache-livy-0.7.0-incubating-bin/logs
  cd /usr/local/livy  
  bin/livy-server
fi

if [[ "${HOSTNAME}" =~ "sparkmaster" ]]; then
  ${SPARK_HOME}/sbin/start-master.sh
  LOG_DIR=${SPARK_HOME}/logs
fi

if [[ "${HOSTNAME}" =~ "worker" ]]; then
  count=0 && while [[ $count -lt 15 && -z `curl -sf http://${SPARK_MASTER}:8080` ]]; do echo "Waiting for sparkmaster - http://${SPARK_MASTER}:8080" ; ((count=count+1)) ; sleep 2; done
  ${SPARK_HOME}/sbin/start-slave.sh spark://${SPARK_MASTER}:7077 -c ${SPARK_CPU_LIMIT} -m ${SPARK_MEM_LIMIT} -h `hostname --fqdn` -p 4041
  LOG_DIR=${SPARK_HOME}/logs
fi 

if [[ "${HOSTNAME}" =~ "thrift" ]]; then
  count=0 && while [[ $count -lt 15 && -z `curl -sf http://${SPARK_MASTER}:8080` ]]; do echo "Waiting for sparkmaster - http://${SPARK_MASTER}:8080" ; ((count=count+1)) ; sleep 2; done
  ${SPARK_HOME}/sbin/start-thriftserver.sh --name Scale --master spark://${SPARK_MASTER}:7077 --total-executor-cores 2
  LOG_DIR=${SPARK_HOME}/logs
fi 

if [[ "${BOOTSTRAP}" =~ "yarn-nm" ]]; then
  sed -i '/<\/configuration>/d' $HADOOP_HOME/etc/hadoop/yarn-site.xml
  cat >> $HADOOP_HOME/etc/hadoop/yarn-site.xml <<- EOM
  <property>
    <name>yarn.nodemanager.resource.memory-mb</name>
    <value>${MY_MEM_LIMIT:-2048}</value>
  </property>

  <property>
    <name>yarn.nodemanager.resource.cpu-vcores</name>
    <value>${MY_CPU_LIMIT:-2}</value>
  </property>
EOM
  echo '</configuration>' >> $HADOOP_HOME/etc/hadoop/yarn-site.xml
  cp ${CONFIG_DIR}/start-yarn-nm.sh $HADOOP_HOME/sbin/
  cd $HADOOP_HOME/sbin
  chmod +x start-yarn-nm.sh

  #  wait up to 30 seconds for resourcemanager
  count=0 && while [[ $count -lt 15 && -z `curl -sf http://yarn-rm:8088/ws/v1/cluster/info` ]]; do echo "Waiting for yarn-rm" ; ((count=count+1)) ; sleep 2; done
  [[ $count -eq 15 ]] && echo "Timeout waiting for yarn-rm, exiting." && exit 1

  ./start-yarn-nm.sh
fi

if [[ "${HOSTNAME}" =~ "jenkins" ]]; then
    /usr/local/bin/jenkins.sh
fi

if [[ $1 == "-d" ]]; then
  until find ${LOG_DIR} -mmin -1 | egrep -q '.*'; echo "`date`: Waiting for logs..." ; do sleep 2 ; done
  find ${LOG_DIR} -mmin -1 | egrep -q '.*'
  tail -F ${LOG_DIR}/* /tmp/scale.log &
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi
