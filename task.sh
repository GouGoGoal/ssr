#!/bin/bash

if [ ! "`grep tcp_ecn /etc/sysctl.conf`" ];then 
	echo 'net.ipv4.tcp_ecn = 1'>>/etc/sysctl.conf
	sysctl -p
fi

sed 's|/master/nginx/tls/|/soga/|g' /etc/crontab