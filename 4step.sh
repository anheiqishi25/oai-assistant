#!/bin/bash
cd ~/oai/openair-epc-fed
pwd

# docker network create --attachable --subnet 192.168.61.0/26 --ip-range 192.168.61.0/26 prod-oai-public-net
# docker run --name prod-cassandra -d -e CASSANDRA_CLUSTER_NAME="OAI HSS Cluster" -e CASSANDRA_ENDPOINT_SNITCH=GossipingPropertyFileSnitch cassandra:2.1
# docker run --privileged --name prod-oai-hss -d --entrypoint /bin/bash oai-hss:production -c "sleep infinity"
# docker network connect prod-oai-public-net prod-oai-hss
# docker run --privileged --name prod-oai-mme --network prod-oai-public-net -d --entrypoint /bin/bash oai-mme:production -c "sleep infinity"
# docker run --privileged --name prod-oai-spgwc --network prod-oai-public-net -d --entrypoint /bin/bash oai-spgwc:production -c "sleep infinity"
# docker run --privileged --name prod-oai-spgwu-tiny --network prod-oai-public-net -d --entrypoint /bin/bash oai-spgwu-tiny:production -c "sleep infinity"

docker inspect --format="{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" prod-oai-mme


# Cassnandra
echo "########################################"
echo "Cassandra"
echo "########################################"
docker cp component/oai-hss/src/hss_rel14/db/oai_db.cql prod-cassandra:/home
docker exec -it prod-cassandra /bin/bash -c "nodetool status"
Cassandra_IP=`docker inspect --format="{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" prod-cassandra`
docker exec -it prod-cassandra /bin/bash -c "cqlsh --file /home/oai_db.cql ${Cassandra_IP}"

# HSS
echo "########################################"
echo "HSS"
echo "########################################"
HSS_IP=`docker exec -it prod-oai-hss /bin/bash -c "ifconfig eth1 | grep inet" | sed -f ./ci-scripts/convertIpAddrFromIfconfig.sed`
python3 component/oai-hss/ci-scripts/generateConfigFiles.py --kind=HSS --cassandra=${Cassandra_IP} --hss_s6a=${HSS_IP} --apn1=apn1.carrier.com --apn2=apn2.carrier.com  --users=200 --imsi=320230100000001 --ltek=0c0a34601d4f07677303652c0462535b --op=63bfa50ee6523365ff14c1f45f88737d --nb_mmes=1 --from_docker_file
docker cp ./hss-cfg.sh prod-oai-hss:/openair-hss/scripts
docker exec -it prod-oai-hss /bin/bash -c "cd /openair-hss/scripts && chmod 777 hss-cfg.sh && ./hss-cfg.sh"

# MME
echo "########################################"
echo "MME"
echo "########################################"
MME_IP=`docker inspect --format="{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" prod-oai-mme`
SPGW0_IP=`docker inspect --format="{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" prod-oai-spgwc`
python3 component/oai-mme/ci-scripts/generateConfigFiles.py --kind=MME --hss_s6a=${HSS_IP} --mme_s6a=${MME_IP} --mme_s1c_IP=${MME_IP} --mme_s1c_name=eth0 --mme_s10_IP=${MME_IP} --mme_s10_name=eth0 --mme_s11_IP=${MME_IP} --mme_s11_name=eth0 --spgwc0_s11_IP=${SPGW0_IP} --mcc=320 --mnc=230 --tac_list="5 6 7" --from_docker_file
docker cp ./mme-cfg.sh prod-oai-mme:/openair-mme/scripts
docker exec -it prod-oai-mme /bin/bash -c "cd /openair-mme/scripts && chmod 777 mme-cfg.sh && ./mme-cfg.sh"

# SPGWC
echo "########################################"
echo "SPGWC"
echo "########################################"
python3 component/oai-spgwc/ci-scripts/generateConfigFiles.py --kind=SPGW-C --s11c=eth0 --sxc=eth0 --apn=apn1.carrier.com --dns1_ip=114.114.114.114 --dns2_ip=8.8.8.8 --push_protocol_option=yes --from_docker_file
docker cp ./spgwc-cfg.sh prod-oai-spgwc:/openair-spgwc
docker exec -it prod-oai-spgwc /bin/bash -c "cd /openair-spgwc && chmod 777 spgwc-cfg.sh && ./spgwc-cfg.sh"

# SPGWU-TINY
echo "########################################"
echo "SPGWU-TINY"
echo "########################################"
python3 component/oai-spgwu-tiny/ci-scripts/generateConfigFiles.py --kind=SPGW-U --sxc_ip_addr=${SPGW0_IP} --sxu=eth0 --s1u=eth0 --network_ue_nat_option=yes --from_docker_file
docker cp ./spgwu-cfg.sh prod-oai-spgwu-tiny:/openair-spgwu-tiny
docker exec -it prod-oai-spgwu-tiny /bin/bash -c "cd /openair-spgwu-tiny && chmod 777 spgwu-cfg.sh && ./spgwu-cfg.sh"
