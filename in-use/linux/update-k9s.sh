#/bin/bash

if [ -z "$1" ]
then
	echo "First argument must be k9s tag: https://github.com/derailed/k9s/releases/tag"
	exit 1
fi

k9s_version=$1

echo "Updating k9s to ${k9s_version} version"

wget -q https://github.com/derailed/k9s/releases/download/${k9s_version}/k9s_${k9s_version}_Linux_x86_64.tar.gz

rm -f latest/*
tar -xvf k9s_${k9s_version}_Linux_x86_64.tar.gz -C latest