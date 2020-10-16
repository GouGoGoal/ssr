#!/bin/bash
sed -i '/.*amazonaws.com.*/d' /etc/smartdns.sh
rm -rf /tmp/smartdns_tmp
rm -rf /etc/smartdns.conf

