#!/bin/bash
set -e
set -x

sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
arch=`uname -m`
if [ $arch == "ppc64le" ]
then
   sudo add-apt-repository \
   "deb [arch=ppc64el] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
else
   sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
fi
sudo apt-get -y update -qq

sudo apt-get purge lxc-docker
sudo apt-cache policy docker-engine

# AUFS
sudo apt-get -y install linux-image-extra-$(uname -r)

# DOCKER
sudo apt-get install -y --force-yes docker-ce

# enable (security - use 127.0.0.1)
sudo -E bash -c 'echo '\''DOCKER_OPTS="-H tcp://0.0.0.0:4243 -H unix:///var/run/docker.sock --storage-driver=aufs"'\'' >> /etc/default/docker'
sudo gpasswd -a `whoami` docker

# Set DOCKER_HOST as an environment variable
sudo -E bash -c 'echo '\''export DOCKER_HOST="tcp://0.0.0.0:4243"'\'' >> /etc/bash.bashrc'
source /etc/bash.bashrc

sudo service docker restart

# do not run this command without a vagrant reload during provisioning
# it gives an error that docker is not up (which the reload fixes).
# sudo docker version
