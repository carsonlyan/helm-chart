#!/bin/bash

echo 'restore users'
rm -fr /tmp/.userbackup
hadoop fs -copyToLocal /user/root/.userbackup /tmp
cp /tmp/.userbackup/* /etc || true
rm -fr /tmp/.userbackup

for D in $(ls -1 /home | grep -v root | grep -v admin)
do
	su $D -c /home/root/user-init.sh
done
