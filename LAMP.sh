#!/bin/bash

cd ~
sudo apt install git -y
git clone https://www.github.com/hawk6242/LinuxScripts
cd LinuxScripts
chmod +x *.sh
./RemoveBloat.sh
./Updates.sh
sudo ufw enable
sudo ufw allow 21
sudo ufw allow 80
sudo ufw allow 3306

sudo apt install apache2 apache2-utils php7.2 php7.2-mysql libapache2-mod-php7.2 php7.2-cli php7.2-cgi php7.2-gd htop vim mysql-client mysql-server vsftpd -y
sudo apt autoremove -y
sudo systemctl enable apache2
sudo systemctl enable vsftpd
sudo systemctl enable mysql-server

cd /var/www/html
sudo touch info.php
echo "<?php phpinfo();?>" | sudo tee info.php

sudo useradd lamp
echo "ccdc2019:lamp" | sudo chpasswd
sudo usermod -aG www-data lamp

cd /tmp
mkdir TEMP
cd TEMP
touch SecureInstall.sql
echo "UPDATE mysql.user SET authentication_string=PASSWORD('PASSWORD') WHERE User='root';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';
FLUSH PRIVILEGES;
create database WP_database;
create user 'USER'@'%' identified by 'PASSWORD';
GRANT ALL PRIVILEGES ON *.* TO 'alice'@'%' WITH GRANT OPTION;
SHOW GRANTS FOR USER;
FLUSH PRIVILEGES;" > SecureInstall.sql
sudo mysql -sfu root < "SecureInstall.sql"

cd /tmp/TEMP/
wget -c http://wordpress.org/latest.tar.gz
tar xvf latest.tar.gz

echo "Edit the apache2 config for root directory as wordpress folder"

sudo mv wordpress/ /var/www/html
sudo nano /etc/apache2/sites-available/000-default.conf 
sudo apachectl configtest
if [ "Syntax OK"=true ]; then
	sudo systemctl restart apache2
else 
	sudo nano /etc/apache2/sites-available/000-default.conf
fi

sudo chown root:root /var/www
sudo chown www-data:www-data -R /var/www/*
sudo chmod -R 755 /var/www
sudo chmod g+s /var/www/html
