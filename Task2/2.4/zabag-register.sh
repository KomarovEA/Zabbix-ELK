#!/bin/bash
# Registering Zabbix Agent on Zabbix server
ZABBIX_Server=$1
ZABBIX_Agent=$2
HostGroup=$3
TemplateName=$4
ZABBIX_USER=$5
ZABBIX_PASS=$6

ZABBIX_API="http://$ZABBIX_Server/api_jsonrpc.php"
# installing jq
wget http://stedolan.github.io/jq/download/linux64/jq
chmod +x ./jq
sudo cp -f jq /usr/bin

#yum -y install http://repo.zabbix.com/zabbix/3.2/rhel/7/x86_64/zabbix-release-3.2-1.el7.noarch.rpm
# stop zabbix agent
systemctl stop zabbix-agent
# Authenticate with Zabbix API
authenticate() {
curl -X POST -H 'Content-Type: application/json-rpc' -d "{\"params\": {\"password\": \"$ZABBIX_PASS\", \"user\": \"$ZABBIX_USER\"}, \"jsonrpc\":\"2.0\", \"method\": \"user.login\", \"id\": 0}" $ZABBIX_API | jq '.result'
}
AUTH_TOKEN=$(authenticate)
# Get TemplateID of template named $TemplateName 
get_template_id() {
  curl -X POST -H 'Content-Type: application/json-rpc' -d "{\"jsonrpc\":\"2.0\",\"method\":\"template.get\",\"params\":{\"output\": \"extend\",\"filter\":{\"host\":[\"$TemplateName\"]}},\"auth\":\"$AUTH_TOKEN\",\"id\":1}" $ZABBIX_API | jq '.templateid'
}

TEMPLATEID=$(get_template_id)



# Create HostGroup named $HostGroup
create_host_grop() {
   curl -X POST -H 'Content-Type: application/json-rpc' -d "{\"params\": {\"name\": \"$HostGroup\"}, \"jsonrpc\": \"2.0\", \"method\": \"hostgroup.create\",\"auth\": \"$AUTH_TOKEN\", \"id\": 2}" $ZABBIX_API | jq '.groupids'
}
# Get groupids of $HostGroup
get_host_group_id() {
curl -X POST -H 'Content-Type: application/json-rpc' -d "{\"jsonrpc\":\"2.0\",\"method\":\"hostgroup.get\",\"params\":{\"output\": \"extend\",\"filter\":{\"name\":[\"$HostGroup\"]}},\"auth\":\"$AUTH_TOKEN\",\"id\":5}" $ZABBIX_API | jq '.groupids';
}

HOSTGROUPID=""
# If HostGroup named $HostGroup doesn't exist
if (HOSTGROUPID=$(get_host_group_id) -eq "") then
# Create HostGroup named $HostGroup
HOSTGROUPID=$(create_host_grop);
fi;


# Create Host
create_host() {
  curl -X POST -H 'Content-Type: application/json-rpc' -d "{\"jsonrpc\":\"2.0\",\"method\":\"host.create\",\"params\":{\"host\":\"$ZABBIX_Agent\",\"ip\":\"$ZABBIX_Agent\",\"dns\":\"$ZABBIX_Agent\",\"port\":10050,\"useip\":1,\"groups\":[{\"groupid\":$HOSTGROUPID}],\"templates\":[{\"templateid\":$TEMPLATEID}]},\"auth\":\"$AUTH_TOKEN\",\"id\":7}" $ZABBIX_API | jq '.hostids'
}
output=$(create_host)
