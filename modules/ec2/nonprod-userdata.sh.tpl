#!/bin/bash
yum update -y
yum install -y httpd
systemctl enable httpd
systemctl start httpd

PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

cat <<HTML > /var/www/html/index.html
<html>
  <head><title>${environment} VM</title></head>
  <body>
    <h1>${owner_name}</h1>
    <p>Environment: ${environment}</p>
    <p>Private IP: $PRIVATE_IP</p>
    <p>VM: ${vm_number}</p>
  </body>
</html>
HTML