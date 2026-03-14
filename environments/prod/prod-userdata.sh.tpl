#!/bin/bash
set -e

yum update -y
yum install -y mariadb1011-server

systemctl enable mariadb
systemctl start mariadb
