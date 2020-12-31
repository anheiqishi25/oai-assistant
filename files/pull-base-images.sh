#!/bin/bash
# https://blog.csdn.net/liangllhahaha/article/details/92077065
sudo groupadd docker
sudo gpasswd -a $xxx docker
sudo gpasswd -a $USER docker
newgrp docker
docker login
docker pull ubuntu:bionic
docker pull cassandra:2.1
docker logout
sudo sysctl net.ipv4.conf.all.forwarding=1
# Need to config follow configuration
sudo iptables -P FORWARD ACCEPT
cd ~
mkdir oai
cd oai
git clone https://github.com/OPENAIRINTERFACE/openair-epc-fed.git
cd openair-epc-fed
git checkout master
git pull origin master
./scripts/syncComponents.sh
# Build HSS Image
docker build --target oai-hss --tag oai-hss:production --file component/oai-hss/docker/Dockerfile.ubuntu18.04 component/oai-hss
docker image prune --force
docker image ls

# Build MME Image
docker build --target oai-mme --tag oai-mme:production --file component/oai-mme/docker/Dockerfile.ubuntu18.04 component/oai-mme
docker image prune --force
docker image ls

# Build SPGW-C Image
docker build --target oai-spgwc --tag oai-spgwc:production --file component/oai-spgwc/docker/Dockerfile.ubuntu18.04 component/oai-spgwc
docker image prune --force
docker image ls

# Build SPGW-U Image
docker build --target oai-spgwu-tiny --tag oai-spgwu-tiny:production --file component/oai-spgwu-tiny/docker/Dockerfile.ubuntu18.04 component/oai-spgwu-tiny
docker image prune --force
docker image ls

