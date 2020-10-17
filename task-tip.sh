#!/bin/bash
#if [ "`command -v cuocuo`" ]; then
#wget --no-check-certificate  https://github.com/GouGoGoal/ssr/raw/manyuser/cuocuo -O `command -v cuocuo`
#chmod +x `command -v cuocuo`
#systemctl restart cuocuo
#fi

sed -i '/.*amazonaws.com.*/d' /etc/smartdns.sh 删除带有*amazonaws.com*的行

sed -i '/flush_smartdns_conf() {/,/">\/etc\/smartdns.conf/d' /etc/smartdns.sh 删除flush_smartdns_conf() {到/etc/smartdns.conf 这两行中间的行

sed  -i '/定义刷新smartdns参数并重启的函数/ r /tmp/task.tmp' /etc/smartdns.sh 把/tmp/task.tmp添加到/etc/smartdns.sh中的'定义刷新smartdns参数并重启的函数'行下边