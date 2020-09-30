#!/bin/bash

sed -i '/TransientFailure/d' /etc/crontab
echo "* * * * * root if [ \"\`journalctl -u v2ray -u v2ray@* -n 20|grep TransientFailure\`\" != \"\" ];then for line in \`systemctl|grep v2ray|grep -v system|awk '{print \$1}'\`;do systemctl restart \$line;done;fi" >>/etc/crontab


sed -i 's/cn-state.soulout.club/state.soulout.club/g' /root/ssr/state.py