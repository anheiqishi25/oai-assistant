#!/bin/bash
# https://github.com/OPENAIRINTERFACE/openair-epc-fed/blob/master/docs/RUN_CNF.md
rm -Rf archives
mkdir -p archives/oai-hss-cfg archives/oai-mme-cfg archives/oai-spgwc-cfg archives/oai-spgwu-cfg

docker cp prod-oai-hss:/openair-hss/etc/. archives/oai-hss-cfg
docker cp prod-oai-mme:/openair-mme/etc/. archives/oai-mme-cfg
docker cp prod-oai-spgwc:/openair-spgwc/etc/. archives/oai-spgwc-cfg
docker cp prod-oai-spgwu-tiny:/openair-spgwu-tiny/etc/. archives/oai-spgwu-cfg

docker cp prod-oai-hss:/openair-hss/hss_check_run.log archives
docker cp prod-oai-mme:/openair-mme/mme_check_run.log archives
docker cp prod-oai-spgwc:/openair-spgwc/spgwc_check_run.log archives
docker cp prod-oai-spgwu-tiny:/openair-spgwu-tiny/spgwu_check_run.log archives

docker cp prod-oai-hss:/tmp/hss_check_run.pcap archives
docker cp prod-oai-mme:/tmp/mme_check_run.pcap archives
docker cp prod-oai-spgwc:/tmp/spgwc_check_run.pcap archives
docker cp prod-oai-spgwu-tiny:/tmp/spgwu_check_run.pcap archives

zip -r -qq docker_files.zip archives