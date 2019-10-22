#!/bin/bash
### This script installing Logstash agent on Tomcat's VM ###
### Input parameters: <Elasticsearch + Kibana server's address> <Tomcat + Logstash agent VM's address> ###
cd ~
#Install Java
yum -y -d1 install java-1.8.0-openjdk-devel
yum -y -d1 install net-tools

# Install Logstash
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
cat <<EOFLR > /etc/yum.repos.d/logstash.repo
[logstash-7.x]
name=Elastic repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOFLR
yum -y -d1 install logstash

cat <<EOFLSTMC > /etc/logstash/conf.d/tomcat8.conf
input {
  file {
    path => "/opt/tomcat/logs/*"
    start_position => "beginning"
  }
}

output {
  elasticsearch {
    hosts => ["$1:9200"]
  }
  stdout { codec => rubydebug }
}
EOFLSTMC
# set rights for logstash to read tomcat's logs
chmod 644 /opt/tomcat/logs/*
chmod 745 /opt/tomcat/logs/

systemctl enable logstash.service
systemctl restart logstash.service

