Vagrant.configure("2") do |config|

	$domain = "my.home"
	$etcd_name_prefix = "etcd-server"
	$swarm_name_prefix = "swarm-node"
	$k8s_name_prefix = "k8s"
	$k8s_srv_prefix = "master"
	$k8s_slv_prefix = "worker"
	# aws t2.micro instance
	$t2_micro_mem = 1024
	$t2_micro_cpu = 1
	# awm t2.medium instance
	$t2_medium_mem = 4096
	$t2_medium_cpu = 2
	# aws t2.nano instance
	$t2_nano_mem = 512
	$t2_nano_cpu = 1
	# aws t2.small instance
	$t2_nano_mem = 2048
	$t2_nano_cpu = 1
	# t2.small
	$k8s_srv_mem = 2048 				# RAM in Gb
	$k8s_srv_cpu = 2					# CPU count
	# 
	$k8s_slv_mem = 4096 				# RAM in Gb
	$k8s_slv_cpu = 2					# CPU count
	
	$k8s_master_begin_ip_range = 10
	$k8s_worker_begin_ip_range = 20
	$swarm_node_begin_ip_range = 99
	$etcd_begin_ip_range = 50
	$private_net = "192.168.0."
	$vbox_img = "centos/7"

	# Run swarm
	[1].each do |i|
		config.vm.define "#{$swarm_name_prefix}#{i}" do |node|
			node.vm.box = "#{$vbox_img}"
			node.vm.hostname = "#{$swarm_name_prefix}#{i}.#{$domain}"
			node.vm.network :private_network, ip: "#{$private_net}#{$swarm_node_begin_ip_range+i}"
#			node.vbguest.auto_update = false
			node.vm.provider :virtualbox do |vb|
				vb.customize [
					"modifyvm", :id,
					"--cpuexecutioncap", "60",
					"--memory", "2048",
					"--cpus", "1",
					"--audio", "none",
				]
			node.vm.provision "shell", inline: <<-SHELL
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






			SHELL
			end
		end
	end



	[2].each do |i|
		config.vm.define "#{$swarm_name_prefix}#{i}" do |node|
			node.vm.box = "#{$vbox_img}"
			node.vm.hostname = "#{$swarm_name_prefix}#{i}.#{$domain}"
			node.vm.network :private_network, ip: "#{$private_net}#{$swarm_node_begin_ip_range+i}"
#			node.vbguest.auto_update = false
			node.vm.provider :virtualbox do |vb|
				vb.customize [
					"modifyvm", :id,
					"--cpuexecutioncap", "60",
					"--memory", "2048",
					"--cpus", "1",
					"--audio", "none",
				]
			node.vm.provision "shell", inline: <<-SHELL
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
#docker-compose up -d

echo "[TASK 12] Set root password"

			SHELL
			end
		end
	end



end