#!/bin/bash
set -e

yum update -y
yum install -y mariadb1011-server

systemctl enable mariadb
systemctl start mariadb

# wait a moment for DB to fully start
sleep 10

# create remote DB user for bastion access
mysql <<EOF
CREATE USER 'hdhnguyen'@'%' IDENTIFIED BY 'duchuy2712';
GRANT ALL PRIVILEGES ON *.* TO 'hdhnguyen'@'%';
FLUSH PRIVILEGES;
EOF