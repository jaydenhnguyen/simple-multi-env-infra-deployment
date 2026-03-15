#!/bin/bash
set -e

yum update -y

# install MySQL/MariaDB client
yum install -y mariadb105

# verify client installed
mysql --version