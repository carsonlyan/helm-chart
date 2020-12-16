#!/bin/bash

set -e

while [[ $# -ge 1 ]]; do
	case $1 in
		-t|--tag )
			tag=$2
			shift 2
			;;
		-h|--helmDir )
			helmDir=$2
			shift 2
			;;
		* )
			echo "invalid argument:$1"
			shift
			;;
    esac
done

if [[ -z ${tag} ]]; then
  imageTag="latest"
fi

if [[ -z ${helmDir} ]]; then
  helmDir=$(pwd)
fi
echo 'upgrade scale'
cd $helmDir
helm -n vtd upgrade scale . --set imageTag=$tag

echo 'upgrade scale complete'
exit
