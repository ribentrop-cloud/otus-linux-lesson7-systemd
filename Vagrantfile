# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
config.vm.define "vm-systemd" do |subconfig|
	subconfig.vm.box = "centos/7"
	subconfig.vm.hostname = "vm-systemd"
	subconfig.vm.network :private_network, ip: "192.168.50.11"
	subconfig.vm.provider "virtualbox" do |vb|
		vb.memory = "1024"
		vb.cpus = "1"
	end
end

config.vm.provision "shell",inline: "yum install -y net-tools nc wget java-1.8.0-openjdk-devel"

# --- 1. Provisioning to create watchdog service and timer ---
config.vm.provision "file", source: "./provisioning_files", destination: "/tmp/provisioning_files"
config.vm.provision "shell",inline: "sudo mv /tmp/provisioning_files/watchdog.log /var/log"
config.vm.provision "shell",inline: "sudo mv /tmp/provisioning_files/watchdog.sh /root/watchdog.sh"
config.vm.provision "shell",inline: "sudo mv /tmp/provisioning_files/watchdog /etc/sysconfig/watchdog"
config.vm.provision "shell",inline: "sudo mv /tmp/provisioning_files/watchdog.service /etc/systemd/system"
config.vm.provision "shell",inline: "sudo mv /tmp/provisioning_files/watchdog.timer /etc/systemd/system"
config.vm.provision "shell",inline: "sudo systemctl start watchdog.timer"

# --- 2. Provisioning to create multiple httpd instances ---
config.vm.provision "shell", path: "./make-multiple-httpd.sh"

# --- 3. Provisioning to create watchdog service that success on 143 return code ---
config.vm.provision "shell",inline: "sudo mv /tmp/provisioning_files/watchdog_failure.log /var/log"
config.vm.provision "shell",inline: "sudo mv /tmp/provisioning_files/watchdog_failure /etc/sysconfig/watchdog_failure"
config.vm.provision "shell",inline: "sudo mv /tmp/provisioning_files/watchdog_failure.service /etc/systemd/system"
config.vm.provision "shell",inline: "sudo mv /tmp/provisioning_files/watchdog_failure.socket /etc/systemd/system"
config.vm.provision "shell",inline: "sudo mv /tmp/provisioning_files/watchdog_failure.sh /root/watchdog_failure.sh"
#config.vm.provision "shell",inline: "sudo systemctl start watchdog_failure.service"
config.vm.provision "shell",inline: "sudo systemctl start watchdog_failure.socket"

# --- 4. Provisioning to install Jira and make Jira service ---
config.vm.provision "shell",inline: "sudo mv /tmp/provisioning_files/jira.service /etc/systemd/system"
config.vm.provision "shell", path: "./jira-install.sh"

end
