#!/bin/bash
MOUNT_TARGET_IP1="${MOUNT_TARGET_IP1}"
MOUNT_TARGET_IP2="${MOUNT_TARGET_IP2}"
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
sudo yum install -y amazon-efs-utils
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport $MOUNT_TARGET_IP1:/ /var/www/html/
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport $MOUNT_TARGET_IP2:/ /var/www/html/
echo "<h1>Hello World from $(hostname -f) </h1>" > /var/www/html/index.html