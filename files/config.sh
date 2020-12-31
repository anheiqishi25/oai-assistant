#!/bin/bash
path=`pwd`
echo $path
cd $path/component/oai-mme
./scripts/build_mme i
./scripts/build_mme
cd $path/component/oai-hss
./scripts/build_hss_rel14 i
./scripts/build_hss_rel14


cd $path
python3 ./ci-scripts/generate_mme_config_script.py  --kind=MME --mme_s6a=127.0.0.1 --hss_s6a=127.0.0.1 --mme_s1c_ip=127.0.0.1 --mme_s1c_name="lo" --mme_s10_ip=192.168.1.243 --mme_s10_name="wlp3s0" --mme_s11_ip=127.0.0.1 --mme_s11_name="lo" --spgwc0_s11_ip=127.0.0.1 --mme_gid=1 --mme_code=1 --mcc=460 --mnc=01 --tai_list="1 460 01" --realm="openair4G.eur" --prefix="yyy"
