#!/bin/bash

apt-get update
apt-get upgrade -y
apt-get install apache2 -y
systemctl enable apache2
apt-get install unzip -y

cd /tmp
echo "Baixando os aplicativos da aplicacao..."
wget https://github.com/denilsonbonatti/linux-site-dio/archive/refs/heads/main.zip

unzip main.zip
cd linux-site-dio-main
cp -R * /var/www/html 

