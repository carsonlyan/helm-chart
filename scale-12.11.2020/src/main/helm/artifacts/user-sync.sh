#!/bin/bash

echo 'user sync start'
while true
do
	rm -fr /tmp/.userbackup
	hadoop fs -copyToLocal -f /user/root/.userbackup /tmp || true
	cp /tmp/.userbackup/* /etc || true
	sleep 10
done
