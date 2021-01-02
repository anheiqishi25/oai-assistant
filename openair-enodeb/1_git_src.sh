sudo apt update && echo Y | sudo apt upgrade
sudo apt install git
mkdir ~/oai
cd ~/oai
git clone https://gitlab.eurecom.fr/oai/openairinterface5g.git
cd openairinterface5g
source oaienv
cd cmake_targets
./build_oai -h
echo "################################################################################"
echo "Step 2: 2_build_src.sh"
echo "################################################################################"
./2_build_src.sh