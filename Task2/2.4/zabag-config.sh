#!/bin/bash
# Installing and configuring Zabbix Agent on CentOS

#yum -y install http://repo.zabbix.com/zabbix/3.2/rhel/7/x86_64/zabbix-release-3.2-1.el7.noarch.rpm
yum -y install http://repo.zabbix.com/zabbix/4.2/rhel/7/x86_64/zabbix-release-4.2-2.el7.noarch.rpm
yum -y install zabbix-agent
yum -y install zabbix-agent
yum -y install zabbix-agent
yum -y install zabbix-agent
yum -y install zabbix-agent
cat <<EOFZAD >> /etc/zabbix/zabbix_agentd.conf
# Common
PidFile=/var/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix/zabbix_agentd.log
DebugLevel=3
# Passive checks related
Server=$1
Hostname=$2
ListenPort=10050
ListenIP=0.0.0.0
StartAgents=3
EOFZAD
systemctl restart zabbix-agent
systemctl enable zabbix-agent

