#!/bin/bash

sudo yum install -y httpd
sudo mv /usr/lib/systemd/system/httpd.service /usr/lib/systemd/system/httpd@.service
sudo sed  -E -i -s  's/EnvironmentFile.+/EnvironmentFile=\/etc\/sysconfig\/httpd-%i/g'  /usr/lib/systemd/system/httpd@.service
sudo sed  -E -i -s  's/\[Service\]/\[Service\]\nMemoryLimit=10M\nCPUQuota=10%\nTasksAccounting=true\nTasksMax=3\nBlockIOAccounting=true\nBlockIOWeight=777/g' /usr/lib/systemd/system/httpd@.service
sudo cp /etc/sysconfig/httpd /etc/sysconfig/httpd-first
sudo cp /etc/sysconfig/httpd /etc/sysconfig/httpd-second
sudo bash -c 'echo "OPTIONS=-f conf/first.conf" >> /etc/sysconfig/httpd-first'
sudo bash -c 'echo "OPTIONS=-f conf/second.conf" >> /etc/sysconfig/httpd-second'
sudo cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/first.conf
sudo cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/second.conf
sudo sed  -E -i -s  's/Listen.+/Listen 81/g'  /etc/httpd/conf/second.conf
sudo bash -c 'echo "PidFile /var/run/http-second.pid" >> /etc/httpd/conf/second.conf'
sudo systemctl start httpd@first
sudo systemctl start httpd@second
