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
	(1..1).each do |i|
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

firewall-cmd --permanent --zone=public --add-service=nfs
firewall-cmd --permanent --zone=public --add-service=mountd
firewall-cmd --permanent --zone=public --add-service=rpc-bind
firewall-cmd --reload
systemctl restart firewalld
systemctl restart rpcbind
systemctl restart nfs 
systemctl restart sshd

#server - nfs
yum install nfs-utils -y
systemctl enable rpcbind nfs-server
systemctl start rpcbind nfs-server
mkdir /nfsshare
chmod -R 777 /nfsshare
echo '/nfsshare 192.168.0.0/24(rw,sync,no_root_squash,no_all_squash)' > /etc/exports
exportfs -r

echo "[TASK 12] Set root password"
echo "kubeadmin" | passwd --stdin root >/dev/null 2>&1
			SHELL
			end
		end
	end



	(2..2).each do |i|
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
sed -i 's/#Port 22/Port 2222/g' /etc/ssh/sshd_config
semanage port -a -t ssh_port_t -p tcp 22222
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

yum install epel-release -y
yum install -y python-pip
pip install docker-compose
systemctl enable docker
systemctl restart docker

mkdir docker
cd docker
cat > docker-compose.yml <<EOF 
    version: '3.3'
    services:
      wordpress:
        image: wordpress:latest
        restart: always
        links:
          - db:mysql
        ports:
          - "80:80"
        working_dir: /var/www/html
        volumes:
          - "/mnt/nfsshare/wp-content:/var/www/html/wp-content"
        environment:
          WORDPRESS_DB_HOST: db:3306
          WORDPRESS_DB_USER: wordpress
          WORDPRESS_DB_PASSWORD: wordpress
          WORDPRESS_DB_NAME: wordpress 
      db:
        image: mysql:5.7
        restart: always
        volumes:
          - "/mnt/nfsshare/mysql:/var/lib/mysql"
        environment:
          MYSQL_ROOT_PASSWORD: secret
          MYSQL_DATABASE: wordpress
          MYSQL_USER: wordpress
          MYSQL_PASSWORD: wordpress
EOF


docker-compose up

echo "[TASK 12] Set root password"
echo "kubeadmin" | passwd --stdin root >/dev/null 2>&1
			SHELL
			end
		end
	end



end