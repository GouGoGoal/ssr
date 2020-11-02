#!/bin/bash


#更新smartdns服务，让他开机就劫持所有DNS
echo "[Unit]
Description=SmartDNS server
After=network.target NetworkManager.service
Before=rc-local.service
[Service]
Type=simple
ExecStartPre=`which iptables|tail -1` -t nat -A OUTPUT -p udp --dport 53 -j DNAT --to-destination 127.0.0.1:53
ExecStart=`which smartdns|tail -1` -f -c /etc/smartdns.conf
ExecStopPost=`which iptables|tail -1` -t nat -D OUTPUT -p udp --dport 53 -j DNAT --to-destination 127.0.0.1:53
Restart=always
[Install]
WantedBy=multi-user.target" >/etc/systemd/system/smartdns.service
#服务开机自启
systemctl daemon-reload