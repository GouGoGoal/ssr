#!/bin/bash

sed -i 's|/akamaized.net/|/ds-linear-abematv.akamaized.net/|g'  /etc/smartdns.sh

#添加paravi解锁
if [ ! "`cat /etc/smartdns.sh|grep paravi`" ];then
	sed  -i '/.*dmm.com.*/a\#日本Paravi\naddress /paravi.jp/$jpip' /etc/smartdns.sh 
fi

if [ ! "`cat /etc/smartdns.sh|grep britbox`" ];then
	sed  -i '/.*peacocktv.com.*/a\#美国\naddress /britbox.com/$usip\naddress /bbccomm.s.llnwi.net/$usip\naddress /vod-dash-ntham-comm-live.akamaized.net/$usip' /etc/smartdns.sh 
fi

rm -f /etc/smartdns.conf
rm -f /tmp/smartdns_tmp