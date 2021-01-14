#!/bin/bash

echo 'update notebooks'
for D in $(ls -1 /home | grep -v root | grep -v admin)
do
	su $D -c /home/root/user-init.sh
done
