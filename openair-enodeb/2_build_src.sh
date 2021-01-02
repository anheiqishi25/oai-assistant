cd ~/oai/openairinterface5g/
cwd=`pwd`
source oaienv
cd cmake_targets/
echo "Please input proxy address[eg: http://192.168.50.102:52578]"
read proxy
export http_proxy=$proxy
export https_proxy=$proxy
egrep -lRZ "uhd_images_downloader" $cwd | xargs -o -l sed -i -e "s|uhd_images_downloader$|uhd_images_downloader --http-proxy $proxy|g"
./build_oai -I -w USRP --eNB --UE

unset http_proxy
unset https_proxy

echo "################################################################################"
echo "Step 3: 3_run.sh"
echo "################################################################################"
./3_run.sh