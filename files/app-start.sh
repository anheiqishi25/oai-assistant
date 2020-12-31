#!/bin/bash
# https://github.com/OPENAIRINTERFACE/openair-epc-fed/blob/master/docs/CONFIGURE_CONTAINERS.md
# https://github.com/OPENAIRINTERFACE/openair-epc-fed/blob/master/docs/RUN_CNF.md
echo "################################################################################"
echo "# IP FORWARD"
echo "################################################################################"
sudo sysctl net.ipv4.conf.all.forwarding=1
sudo iptables -P FORWARD ACCEPT

echo "################################################################################"
echo "# Start prod-cassandra/prod-oai-hss/prod-oai-mme/prod-oai-spgwc/prod-oai-spgwu-tiny"
echo "################################################################################"
docker start prod-cassandra
docker start prod-oai-hss
docker start prod-oai-mme
docker start prod-oai-spgwc
docker start prod-oai-spgwu-tiny
sleep 15
# docker network connect prod-oai-public-net prod-oai-hss
# On your EPC Docker Host: recover the MME IP address:
# docker inspect --format="{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" prod-oai-mme
# Return MME IP address: 192.168.61.3
# SPGW-U IP address 192.168.61.5

echo "################################################################################"
echo "# Config and boot Cassandra image"
echo "################################################################################"
# docker cp component/oai-hss/src/hss_rel14/db/oai_db.cql prod-cassandra:/home
# docker exec -it prod-cassandra /bin/bash -c "nodetool status"
Cassandra_IP=`docker inspect --format="{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" prod-cassandra`
docker exec -it prod-cassandra /bin/bash -c "cqlsh --file /home/oai_db.cql ${Cassandra_IP}"

echo "################################################################################"
echo "# Config and boot HSS image"
echo "################################################################################"
# HSS_IP=`docker exec -it prod-oai-hss /bin/bash -c "ifconfig eth1 | grep inet" | sed -f ./ci-scripts/convertIpAddrFromIfconfig.sed`
# python3 component/oai-hss/ci-scripts/generateConfigFiles.py --kind=HSS --cassandra=${Cassandra_IP} --hss_s6a=${HSS_IP} --apn1=apn1.carrier.com --apn2=apn2.carrier.com --users=200 --imsi=320230100000001 --ltek=0c0a34601d4f07677303652c0462535b --op=63bfa50ee6523365ff14c1f45f88737d --nb_mmes=1 --from_docker_file
# docker cp ./hss-cfg.sh prod-oai-hss:/openair-hss/scripts
docker exec -it prod-oai-hss /bin/bash -c "cd /openair-hss/scripts && chmod 777 hss-cfg.sh && ./hss-cfg.sh"

echo "################################################################################"
echo "# Config and boot MME image"
echo "################################################################################"
# MME_IP=`docker inspect --format="{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" prod-oai-mme`
# SPGW0_IP=`docker inspect --format="{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" prod-oai-spgwc`
# python3 component/oai-mme/ci-scripts/generateConfigFiles.py --kind=MME --hss_s6a=${HSS_IP} --mme_s6a=${MME_IP} --mme_s1c_IP=${MME_IP} --mme_s1c_name=eth0 --mme_s10_IP=${MME_IP} --mme_s10_name=eth0 --mme_s11_IP=${MME_IP} --mme_s11_name=eth0 --spgwc0_s11_IP=${SPGW0_IP} --mcc=320 --mnc=230 --tac_list="5 6 7" --from_docker_file
# docker cp ./mme-cfg.sh prod-oai-mme:/openair-mme/scripts
docker exec -it prod-oai-mme /bin/bash -c "cd /openair-mme/scripts && chmod 777 mme-cfg.sh && ./mme-cfg.sh"

echo "################################################################################"
echo "# Config and boot SPGW-C image"
echo "################################################################################"
# python3 component/oai-spgwc/ci-scripts/generateConfigFiles.py --kind=SPGW-C --s11c=eth0 --sxc=eth0 --apn=apn1.carrier.com --dns1_ip=114.114.114.114 --dns2_ip=8.8.8.8 --from_docker_file
# docker cp ./spgwc-cfg.sh prod-oai-spgwc:/openair-spgwc
docker exec -it prod-oai-spgwc /bin/bash -c "cd /openair-spgwc && chmod 777 spgwc-cfg.sh && ./spgwc-cfg.sh"

echo "################################################################################"
echo "# Config and boot SPGW-U-TINY image"
echo "################################################################################"
# python3 component/oai-spgwu-tiny/ci-scripts/generateConfigFiles.py --kind=SPGW-U --sxc_ip_addr=${SPGW0_IP} --sxu=eth0 --s1u=eth0 --from_docker_file
# docker cp ./spgwu-cfg.sh prod-oai-spgwu-tiny:/openair-spgwu-tiny
docker exec -it prod-oai-spgwu-tiny /bin/bash -c "cd /openair-spgwu-tiny && chmod 777 spgwu-cfg.sh && ./spgwu-cfg.sh"


echo "################################################################################"
echo "# log setting"
echo "################################################################################"
docker exec -d prod-oai-hss /bin/bash -c "nohup tshark -i eth0 -i eth1 -w /tmp/hss_check_run.pcap 2>&1 > /dev/null"
docker exec -d prod-oai-mme /bin/bash -c "nohup tshark -i eth0 -i lo:s10 -w /tmp/mme_check_run.pcap 2>&1 > /dev/null"
docker exec -d prod-oai-spgwc /bin/bash -c "nohup tshark -i eth0 -i lo:p5c -i lo:s5c -w /tmp/spgwc_check_run.pcap 2>&1 > /dev/null"
docker exec -d prod-oai-spgwu-tiny /bin/bash -c "nohup tshark -i eth0 -w /tmp/spgwu_check_run.pcap 2>&1 > /dev/null"
echo "################################################################################"
echo "# run app"
echo "################################################################################"
docker exec -d prod-oai-hss /bin/bash -c "nohup ./bin/oai_hss -j ./etc/hss_rel14.json --reloadkey true > hss_check_run.log 2>&1"
sleep 2
docker exec -d prod-oai-mme /bin/bash -c "nohup ./bin/oai_mme -c ./etc/mme.conf > mme_check_run.log 2>&1"
sleep 2
docker exec -d prod-oai-spgwc /bin/bash -c "nohup ./bin/oai_spgwc -o -c ./etc/spgw_c.conf > spgwc_check_run.log 2>&1"
sleep 2
docker exec -d prod-oai-spgwu-tiny /bin/bash -c "nohup ./bin/oai_spgwu -o -c ./etc/spgw_u.conf > spgwu_check_run.log 2>&1"