#!/bin/bash

# for your information
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-lamp-amazon-linux-2.html

#----------------------------------------------
#httpd
#----------------------------------------------
yum install httpd -y

#----------------------------------------------
#php
#----------------------------------------------
amazon-linux-extras install -y php7.2
yum install php-mbstring -y

#----------------------------------------------
#phpmyadmin
#----------------------------------------------
wget https://files.phpmyadmin.net/phpMyAdmin/5.0.2/phpMyAdmin-5.0.2-all-languages.tar.gz -P /var/www/html/
mkdir /var/www/html/phpMyAdmin && tar -xvzf /var/www/html/phpMyAdmin-5.0.2-all-languages.tar.gz -C /var/www/html/phpMyAdmin --strip-components 1
systemctl start httpd
systemctl restart php-fpm
