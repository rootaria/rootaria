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
	(1..2).each do |i|
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
					"--cpus", "2",
					"--audio", "none",
				]
			node.vm.provision "shell", inline: <<-SHELL
				sed -i 's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/g' /etc/ssh/sshd_config
				systemctl restart sshd
				 echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCrKdP2oy41laB4o/JURkwG1byQIK24N/j792c5ZmA5SNpHEMrgym1J17rR9K+CQ29X7DrK1gzcjq8+RkTnH1J+N86SV9zzyzVSkyz2GyVUDDy0EudrhRzPSc1bVf4xIr5vBb10aXiBC40cY2jXewFJypkKbhRK32ZTf2nFfslZHObAhpe4jCJOEDIZIKy6l9RkMxMEKLy7N4X0cf7ggm6gnxYlfwsN4FL4u73bZ5H4N6/i+lQp8a55sYzu+ESPcezcJpMAM5CYnDUQIOF4YpakJpCqezEacNPFXGTcRYqyQvGDu0jNAqcStjmN3C6ToWabtxdVFjDS3/M+HJrm2X/z root@myVM' > /home/vagrant/.ssh/authorized_keys
			SHELL
			end
		end
	end
end