#!/bin/bash
### This script installing Tomcat and deploy TestApp.jar ###
### Input parameters: <Elasticsearch + Kibana server's address> <Tomcat + Logstash agent VM's address> ###
cd ~
#Install Java
yum -y -d1 install wget
yum -y -d1 install java-1.8.0-openjdk-devel
yum -y -d1 install net-tools
#Create Tomcat User 
groupadd tomcat 
useradd -M -s /bin/nologin -g tomcat -d /opt/tomcat tomcat 
#Install TomCat 
if [ ! -d "/usr/local/tomcat" ] ; then
mkdir /opt/tomcat;
mkdir /usr/local/tomcat;
cd /usr/local/tomcat;
wget -nv -t 10 -nc http://ftp.byfly.by/pub/apache.org/tomcat/tomcat-8/v8.5.47/bin/apache-tomcat-8.5.47.tar.gz;
tar xzf apache-tomcat-8.5.47.tar.gz -C /opt/tomcat --strip-components=1;
fi
#Set permissions: 
cd /opt/tomcat 
chgrp -R tomcat conf 
chmod g+rwx conf 
chmod g+r conf/* 
chown -R tomcat logs/ temp/ webapps/ work/ 
chgrp -R tomcat bin 
chgrp -R tomcat lib 
chmod g+rwx bin 
sudo chmod g+r bin/* 

#Make bin/setenv.sh : 
cat <<EOFSE > /opt/tomcat/bin/setenv.sh
CATALINA_HOME=/opt/tomcat
CATALINA_BASE=/opt/tomcat
JAVA_HOME=/usr
#####CATALINA_OPTS=-Xss1024M -server -XX:+UseParallelGC
#####JAVA_OPTS=-Xms256m -Xmx512M -Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.port=12345 -Dcom.sun.management.jmxremote.rmi.port=12346 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Djava.rmi.server.hostname=192.168.56.223
EOFSE
chmod +x /opt/tomcat/bin/setenv.sh

#Add to /etc/systemd/system/tomcat.service : 
cat <<EOFTS > /etc/systemd/system/tomcat.service
# Systemd unit file for tomcat 
[Unit] 
Description=Apache Tomcat Web Application Container 
After=syslog.target network.target 
[Service] 
Type=forking 
Environment="JAVA_HOME=/usr"
Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"
Environment="CATALINA_HOME=/opt/tomcat"
Environment="CATALINA_BASE=/opt/tomcat" 
####Environment="CATALINA_OPTS="
####Environment="JAVA_OPTS=${JAVA_OPTS}"
ExecStart=/opt/tomcat/bin/startup.sh 
ExecStop=/bin/kill -15 \$MAINPID 
User=tomcat 
Group=tomcat 
#UMask=0007 
#RestartSec=10 
#Restart=always 
[Install] 
WantedBy=multi-user.target 
EOFTS

#Add firewall exeption: 

#firewall-cmd --zone=public --permanent --add-port=8080/tcp 
#firewall-cmd --reload 


#Start tomcat daemon on hosts: 
systemctl daemon-reload
systemctl enable tomcat 
 

# Deploy TestApp into Tomcat
cp /vagrant/TestApp.war /opt/tomcat/webapps/
systemctl restart tomcat
sleep 15
systemctl stop tomcat
#Set Multipart Config in Web.xml for our TestApp (/opt/tomcat/webapps/TestApp/WEB-INF/web.xml ):
cp /opt/tomcat/webapps/TestApp/WEB-INF/web.xml /opt/tomcat/webapps/TestApp/WEB-INF/web.xml.ORIG
cat <<EOFWB > /opt/tomcat/webapps/TestApp/WEB-INF/web.xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee http://xmlns.jcp.org/xml/ns/javaee/web-app_3_1.xsd"
         version="3.1">
    <servlet>
        <servlet-name>GenericServlet</servlet-name>
        <servlet-class>com.epam.nix.java.testapp.servlet.GenericServlet</servlet-class>
          <multipart-config>
          </multipart-config>
    </servlet>
    <servlet-mapping>
        <servlet-name>GenericServlet</servlet-name>
        <url-pattern>/generic/</url-pattern>
    </servlet-mapping>
    <servlet>
        <servlet-name>DeadlockServlet</servlet-name>
        <servlet-class>com.epam.nix.java.testapp.servlet.DeadlockServlet</servlet-class>
    </servlet>
    <servlet-mapping>
        <servlet-name>DeadlockServlet</servlet-name>
        <url-pattern>/deadlock/</url-pattern>
    </servlet-mapping>
    <servlet>
        <servlet-name>MemoryLeakServlet</servlet-name>
        <servlet-class>com.epam.nix.java.testapp.servlet.MemoryLeakServlet</servlet-class>
        <multipart-config>
    		<location>/tmp</location>
    		<max-file-size>20848820</max-file-size>
    		<max-request-size>418018841</max-request-size>
    		<file-size-threshold>1048576</file-size-threshold>
	</multipart-config>
    </servlet>
    <servlet-mapping>
        <servlet-name>MemoryLeakServlet</servlet-name>
        <url-pattern>/memoryleak/</url-pattern>
    </servlet-mapping>
    <servlet>
        <servlet-name>PerformanceIssueServlet</servlet-name>
        <servlet-class>com.epam.nix.java.testapp.servlet.PerformanceIssueServlet</servlet-class>
    </servlet>
    <servlet-mapping>
        <servlet-name>PerformanceIssueServlet</servlet-name>
        <url-pattern>/PerformanceIssue/</url-pattern>
    </servlet-mapping>
</web-app>

EOFWB

chown tomcat:tomcat -R /opt/tomcat
systemctl restart tomcat
