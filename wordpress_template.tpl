#!/bin/bash
MOUNT_TARGET_IP1="${MOUNT_TARGET_IP1}"
MOUNT_TARGET_IP2="${MOUNT_TARGET_IP2}"
DB_HOST="${DB_HOST}"
DB_NAME="${DB_NAME}"
DB_USER="${DB_USER}"
DB_PASSWORD="${DB_PASSWORD}"

yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd

yum install -y amazon-efs-utils
mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport $MOUNT_TARGET_IP1:/ /var/www/html/
mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport $MOUNT_TARGET_IP2:/ /var/www/html/

cd /tmp
curl -O https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cd wordpress
cp wp-config-sample.php wp-config.php

echo "<?php" > wp-config.php
echo "define( 'DB_NAME', '"$DB_NAME"' );" >> wp-config.php
echo "define( 'DB_USER', '"$DB_USER"' );" >> wp-config.php
echo "define( 'DB_PASSWORD', '"${DB_PASSWORD}"' );" >> wp-config.php
echo "define( 'DB_HOST', '"$DB_HOST"' );" >> wp-config.php
echo "define( 'DB_CHARSET', 'utf8' );" >> wp-config.php
echo "define( 'DB_COLLATE', '' );" >> wp-config.php
echo "define('FS_METHOD', 'direct');" >> wp-config.php
echo "/**#@+" >> wp-config.php
echo " */" >> wp-config.php
curl -s https://api.wordpress.org/secret-key/1.1/salt/ >> wp-config.php
echo "/**#@-*/" >> wp-config.php
echo "\$table_prefix = 'wp_';" >> wp-config.php
echo "define( 'WP_DEBUG', true );" >> wp-config.php
echo "define( 'WP_DEBUG_LOG', true );" >> wp-config.php
echo "define( 'SAVEQUERIES', true );" >> wp-config.php
echo "if (\$_SERVER['HTTP_X_FORWARDED_PROTO']== 'https') \$_SERVER['HTTPS']='on';" >> wp-config.php
echo "if ( ! defined( 'ABSPATH' ) ) {" >> wp-config.php
echo "    define( 'ABSPATH', __DIR__ . '/' );" >> wp-config.php
echo "}" >> wp-config.php
echo "require_once ABSPATH . 'wp-settings.php';" >> wp-config.php

amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
cd /tmp
cp -r wordpress/* /var/www/html/
service httpd restart