#!/bin/bash

#添加paravi解锁
if [ ! "`cat /etc/smartdns.sh|grep paravi`" ];then
	sed  -i '/.*dmm.com.*/a\#日本Paravi\naddress /paravi.jp/$jpip' /etc/smartdns.sh 
	rm -f /etc/smartdns.conf
	rm -f /tmp/smartdns_tmp
fi
	