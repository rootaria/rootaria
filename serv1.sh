#!/bin/bash

sed -i 's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/g' /etc/ssh/sshd_config

#disable SELinix
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

#install zabbix java wget mc
rpm -Uvh https://repo.zabbix.com/zabbix/4.4/rhel/7/x86_64/zabbix-release-4.4-1.el7.noarch.rpm
yum install -y epel-release
yum install -y mysql mariadb mariadb-server zabbix-server-mysql zabbix-web-mysql zabbix-apache-conf java wget  policycoreutils-python
sleep 10
systemctl restart firewalld
firewall-cmd --permanent --zone=public --add-service=nfs
firewall-cmd --permanent --zone=public --add-service=mountd
firewall-cmd --permanent --zone=public --add-service=rpc-bind
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=10051/tcp
firewall-cmd --permanent --add-port=10051/udp
firewall-cmd --reload
systemctl restart firewalld
systemctl restart rpcbind
systemctl restart nfs 
systemctl restart sshd
systemctl enable mariadb.service
systemctl start mariadb.service

sed -i 's/        # php_value date/        php_value date/g' /etc/httpd/conf.d/zabbix.conf
sed -i 's/Riga/Samara/g' /etc/httpd/conf.d/zabbix.conf
sed -i 's/# DBHost=/DBHost=/g' /etc/zabbix/zabbix_server.conf
sed -i 's/# DBPassword=/DBPassword=zabbix/g' /etc/zabbix/zabbix_server.conf
mysqladmin -u root password zabbix
mysql -uroot -pzabbix < /vagrant/zabbix_sql
zcat /usr/share/doc/zabbix-server-mysql-4.4.*/create.sql.gz | mysql -uroot -pzabbix zabbix
cp /vagrant/zabbix.conf.php /etc/zabbix/web/

systemctl enable httpd
systemctl restart httpd
systemctl enable zabbix-server
systemctl restart zabbix-server

#server - nfs
yum install nfs-utils -y
systemctl enable rpcbind nfs-server
systemctl start rpcbind nfs-server
mkdir /nfsshare
chmod -R 777 /nfsshare
echo '/nfsshare 192.168.0.0/24(rw,sync,no_root_squash,no_all_squash)' > /etc/exports
exportfs -r

wget https://www-eu.apache.org/dist//jmeter/binaries/apache-jmeter-5.1.1.tgz
mkdir /jmeter
tar -xvzf apache-jmeter-5.1.1.tgz -C /jmeter/
cp /vagrant/build-web-test-plan.jmx /jmeter/

