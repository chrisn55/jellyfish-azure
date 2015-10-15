#!/bin/bash

DB_DNSNAME=$1
DB_IPADDRESS=$2

bash add_host_entry.sh $DB_DNSNAME $DB_IPADDRESS

# install nodejs
curl -sL https://deb.nodesource.com/setup | bash -
apt-get install -y nodejs build-essential

