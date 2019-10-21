#!/bin/bash
# Installing and configuring MySQL DB (MariaDB)
yum -y install mariadb mariadb-server

#  Mysql Initial configuration (before initial start SQL!!!)
mysql_install_db --user=mysql --force
systemctl restart mariadb
systemctl enable mariadb
mysqladmin -u root password ''
mysql -uroot -e "create database IF NOT EXISTS $3 character set utf8 collate utf8_bin";
mysql -uroot -e "grant all privileges on $3.* to $3@localhost identified by '$4'";

# Installing and configuring Zabbix Server

#yum -y install http://repo.zabbix.com/zabbix/4.4/rhel/7/x86_64/zabbix-release-4.4-1.el7.noarch.rpm
yum -y install http://repo.zabbix.com/zabbix/4.2/rhel/7/x86_64/zabbix-release-4.2-2.el7.noarch.rpm
yum -y install zabbix-server-mysql
yum -y install zabbix-server-mysql
yum -y install zabbix-server-mysql
yum -y install zabbix-server-mysql
yum -y install zabbix-server-mysql

#Import initial schema, data and configuring
zcat /usr/share/doc/zabbix-server-mysql-*/create.sql.gz | mysql --database=$2 --user=$3 --password=$4;
#zcat /usr/share/doc/zabbix-server-mysql-3.2.11/create.sql.gz | mysql --database=$2 --user=$3 --password=$4;
#zcat /usr/share/doc/zabbix-server-mysql-4.4/create.sql.gz | mysql --database=$2 --user=$3 --password=$4;
#zcat /usr/share/doc/zabbix-server-mysql-4.2.7/create.sql.gz | mysql --database=$2 --user=$3 --password=$4;
cat <<EOFZCDF >> /etc/zabbix/zabbix_server.conf 
DBHost=localhost
DBName=$2
DBUser=$3
DBPassword=$4

EOFZCDF

systemctl enable zabbix-server
systemctl restart zabbix-server

# Zabbix front-end Installation and Configuration
yum -y install zabbix-web-mysql
yum -y install zabbix-web-mysql
yum -y install zabbix-web-mysql
yum -y install zabbix-web-mysql
yum -y install zabbix-web-mysql

cat <<EOFZCF > /etc/httpd/conf.d/zabbix.conf
#
# Zabbix monitoring system php web frontend
#
DocumentRoot /usr/share/zabbix
#Alias /zabbix /usr/share/zabbix

<Directory "/usr/share/zabbix">
    Options FollowSymLinks
    AllowOverride None
    Require all granted

    <IfModule mod_php5.c>
        php_value max_execution_time 300
        php_value memory_limit 128M
        php_value post_max_size 16M
        php_value upload_max_filesize 2M
        php_value max_input_time 300
        php_value always_populate_raw_post_data -1
        php_value date.timezone Europe/Minsk
    </IfModule>
</Directory>

<Directory "/usr/share/zabbix/conf">
    Require all denied
</Directory>

<Directory "/usr/share/zabbix/app">
    Require all denied
</Directory>

<Directory "/usr/share/zabbix/include">
    Require all denied
</Directory>

<Directory "/usr/share/zabbix/local">
    Require all denied
</Directory>
EOFZCF
# initial server configuration
cp -f /vagrant/zabbix.conf.php /etc/zabbix/web/

systemctl enable httpd
systemctl restart httpd

