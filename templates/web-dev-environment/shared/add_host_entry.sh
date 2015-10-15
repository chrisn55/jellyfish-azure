#!/bin/bash

# You must be root to run this script
if [ "${UID}" -ne 0 ];
then
  echo "Script executed without root permissions"
  echo "You must be root to run this program." >&2
  exit 3
fi

DNSNAME=$1
IPADDRESS=$2

# add the host name if it's not already there
grep -q "${DNSNAME}" /etc/hosts
if [ $? == 0 ];
then
  echo "${DNSNAME} found in /etc/hosts"
else
  echo "${DNSNAME} not found in /etc/hosts"
  # Append it to the hsots file if not there
  echo "${IPADDRESS} ${DNSNAME}" >> /etc/hosts
  echo "hostname ${DNSNAME} added to /etc/hosts"
fi
