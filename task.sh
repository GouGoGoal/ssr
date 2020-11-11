#!/bin/bash


if [ ! "`cat /etc/hosts|grep auth.rico93.com`" ];then 
	echo '127.0.0.1 auth.rico93.com' >>/etc/hosts
fi