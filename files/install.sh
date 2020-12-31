sudo apt update
echo Y | sudo apt install git cmake
echo Y | sudo apt autoremove
# Download OAI sources
git clone https://github.com/OPENAIRINTERFACE/openair-epc-fed.git
cd openair-epc-fed
./scripts/syncComponents.sh --mme-branch master --hss-branch master --spgwc-branch master --spgwu-tiny-branch master
./component/oai-hss/scripts/build_hss_rel14 -i
./component/oai-hss/scripts/build_hss_rel14
./component/oai-mme/scripts/build_mme -i
./component/oai-mme/scripts/build_mme

cwd=`pwd`

# Build OAI sources
git config --global https.proxy https://39.97.175.223:52578

# git config --global --unset https.proxy


# Configurations of MME && SPGW-C SPGW-U
# wget https://anheiqishi25.github.io/oai/config.sh
# chmod a+x config.sh
# ./config.sh

# git clone https://github.com/OPENAIRINTERFACE/openair-mme.git
# git clone https://github.com/OPENAIRINTERFACE/openair-hss.git
# git clone https://github.com/OPENAIRINTERFACE/openair-spgwc.git
# git clone https://github.com/OPENAIRINTERFACE/openair-spgwu-tiny.git

git config --global --unset https.proxy
