#!/bin/bash
### This script installing Elasticsearch + Kibana server ###
### Input parameters: <Elasticsearch + Kibana server's address> <Tomcat + Logstash agent VM's address> ###
cd ~
#Install Java
yum -y -d1 install java-1.8.0-openjdk-devel
yum -y -d1 install net-tools
################ install Elasticsearch ############
# Download and install the public signing key:
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
# Create a file called elasticsearch.repo in the /etc/yum.repos.d/ directory
cat <<EOFER > /etc/yum.repos.d/elasticsearch.repo
[elasticsearch-7.x]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOFER
yum -y -d1 install elasticsearch

cat <<EOFES >> /etc/elasticsearch/elasticsearch.yml
network.host: 0.0.0.0
transport.host: localhost
EOFES
################ install Kibana ############
# Download and install the public signing key:
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
# Create a file called kibana.repo in the /etc/yum.repos.d/ directory 
cat <<EOFKR > /etc/yum.repos.d/kibana.repo 
[kibana-7.x]
name=Kibana repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOFKR

yum -y -d1 install kibana
cat <<EOFIB >> /etc/kibana/kibana.yml
server.host: $1
elasticsearch.hosts: "http://$1:9200"
EOFIB
systemctl daemon-reload
systemctl enable elasticsearch.service
systemctl restart elasticsearch.service
systemctl enable kibana.service
systemctl restart kibana.service
