#!/bin/bash
# https://github.com/OPENAIRINTERFACE/openair-epc-fed/blob/master/docs/CONFIGURE_CONTAINERS.md
# https://github.com/OPENAIRINTERFACE/openair-epc-fed/blob/master/docs/RUN_CNF.md
sudo apt update && echo Y |sudo apt upgrade
sudo apt install git
cd ~ && mkdir oai
cd oai

echo "################################################################################"
git clone https://gitlab.eurecom.fr/oai/openairinterface5g.git
cd openairinterface5g
source oaienv
cd cmake_targets
./build_oai -I -w USRP