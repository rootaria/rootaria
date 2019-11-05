#!/bin/bash
sed -i 's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/g' /etc/ssh/sshd_config

#change port 22 - 22222
sed -i 's/#Port 22/Port 22222/g' /etc/ssh/sshd_config


#disable SELinix
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

#install zabbix java wget mc
rpm -Uvh https://repo.zabbix.com/zabbix/4.4/rhel/7/x86_64/zabbix-release-4.4-1.el7.noarch.rpm
yum install -y epel-release
yum install -y zabbix-agent java wget policycoreutils-python

sleep 10



sed -i 's/Server=127.0.0.1/Server=192.168.0.100/g' /etc/zabbix/zabbix_agentd.conf
sed -i 's/ServerActive=127.0.0.1/ServerActive=192.168.0.100/g' /etc/zabbix/zabbix_agentd.conf
sed -i 's/Hostname=Zabbix server/Hostname=Zabbix server2/g' /etc/zabbix/zabbix_agentd.conf




systemctl enable zabbix-agent
systemctl start zabbix-agent

systemctl restart firewalld
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=10050/tcp
firewall-cmd --permanent --add-port=10050/udp
firewall-cmd --permanent --add-port=10051/tcp
firewall-cmd --permanent --add-port=10051/udp



firewall-cmd --permanent --add-port=22222/tcp
firewall-cmd --permanent --add-port=110/tcp
firewall-cmd --permanent --add-port=110/udp
firewall-cmd --permanent --add-port=662/tcp
firewall-cmd --permanent --add-port=662/udp
firewall-cmd --permanent --add-port=875/tcp
firewall-cmd --permanent --add-port=875/udp
firewall-cmd --permanent --add-port=2049/tcp
firewall-cmd --permanent --add-port=32803/tcp
firewall-cmd --permanent --add-port=32769/tcp
systemctl restart firewalld
systemctl restart nfs 
systemctl restart sshd






#install client nfs
yum install nfs-utils -y
systemctl start rpcbind
systemctl enable rpcbind
mkdir /mnt/nfsshare
mount -t nfs 192.168.0.100:/nfsshare/ /mnt/nfsshare/




#install docker-ce
yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
yum install docker-ce docker-ce-cli containerd.io -y


yum install -y python-pip
pip install docker-compose
systemctl enable docker
systemctl restart docker



mkdir /docker
cp /vagrant/docker-compose.yml /docker/
cd /docker
docker-compose up -d

echo "[TASK 12] Set root password"
