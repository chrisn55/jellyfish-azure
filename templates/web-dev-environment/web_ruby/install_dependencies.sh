#!/bin/bash

DNSNAME=$1
IPADDRESS=$2
USERNAME=$3

bash add_host_entry.sh $DNSNAME $IPADDRESS

# install dependencies
apt-get update
apt-get install -y git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev
apt-get install -y sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev ruby-dev
apt-get install -y libgdbm-dev libncurses5-dev automake libtool bison libffi-dev libgmp-dev

# install nodejs
curl -sL https://deb.nodesource.com/setup | bash -
apt-get install -y nodejs

# run the install ruby script
cp install_ruby.sh /home/$USERNAME/
cd /home/$USERNAME
chmod +r install_ruby.sh
sudo -u $USERNAME bash install_ruby.sh
rm /home/$USERNAME/install_ruby.sh

