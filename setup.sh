#!/bin/sh

if [ "$1" == '' ];then
echo "未赋值，退出脚本"
exit 0
fi
if [ "$2" == '' ];then
echo "对接URL未填写"
exit 0
fi
if [ "$2" == '' ];then
echo "对接token未填写"
exit 0
fi

#优先使用IPV6地址 
echo "precedence ::ffff:0:0/96  100" >>/etc/gai.conf
if [ ! -f "/etc/redhat-release" ]; then
apt update
#安装环境
apt install -y python3 python3-pip git libsodium-dev vim libssl-dev swig ntp
else 
yum clean all
yum makecache
yum install -y python3 python3-pip git openssl-devel  libffi libffi-dev ntp
#关闭防火墙
systemctl disable firewalld
systemctl stop firewalld
#关闭 selinux
setenforce 0
echo 'SELINUX=disabled' >/etc/selinux/config
fi
#自动同步时间
timedatectl set-ntp true
#下载代码
cd /root
git clone -b manyuser https://github.com/GouGoGoal/ssr
cd ssr
pip3 install --upgrade setuptools 
pip3 install cymysql requests pyOpenSSL ndg-httpsclient pyasn1 pycparser pycryptodome idna speedtest-cli
mv apiconfig.py userapiconfig.py
mv config.json user-config.json

#添加服务
echo "[Unit]
Description=SSR deamon
After=rc-local.service
[Service]
Type=simple
ExecStart=/usr/bin/python3 /root/ssr/server.py
Restart=always
#启动频率限制，开启启动失败时尝试
#StartLimitIntervalSec=180
#StartLimitBurst=90
LimitNOFILE=512000
LimitNPROC=512000
# 柔性限制
# MemoryHigh=95%
# 刚性限制
# MemoryMax=25%
[Install]
WantedBy=multi-user.target">/etc/systemd/system/ssr.service

if [ "$1" != '0' ];then
#传入对接参数
sed -i "s|node_id|$1|" userapiconfig.py
sed -i "s|webapi_url|$2|" userapiconfig.py
sed -i "s|webapi_token|$3|" userapiconfig.py

systemctl enable ssr
systemctl restart ssr
fi

#修改时区
timedatectl set-timezone Asia/Shanghai
#赋予脚本可执行权限
chmod  +x /root/ssr/*.sh
#计划任务改成bash执行
sed -i 's|SHELL=/bin/sh|SHELL=/bin/bash|' /etc/crontab
#添加计划任务
echo '
#每天05:55执行task
55 5 * * * root curl -k https://raw.githubusercontent.com/GouGoGoal/ssr/manyuser/task.sh |bash
#每天05:55清理日志日志
55 5 * * * root find /var/ -name "*.log.*" -exec rm -rf {} \;
#每天06:00点重启
0 6 * * * root init 6
'>>/etc/crontab
rm -rf setup.sh .git .gitignore README.md 
mv besttrace /usr/sbin
chmod +x /usr/sbin/besttrace
mv tcping /usr/sbin
chmod +x /usr/sbin/tcping

if [ "$4" != "0" -a "$4" != ""  ];then
#添加探针服务
echo "[Unit]
Description=state deamon
After=rc-local.service

[Service]
Type=simple
ExecStart=/usr/bin/python3 /etc/state.py
Restart=on-failure
[Install]
WantedBy=multi-user.target">/etc/systemd/system/state.service
mv -f state.py /etc
#传入参数
sed -i "s|node|$4|" /etc/state.py
systemctl enable state
systemctl restart state
echo "$4.lovegoogle.xyz已添加探针"
fi

if [ "$5" == "ovz" ];then
echo "
#关闭IPV6
net.ipv6.conf.all.disable_ipv6 = 1
#开启内核转发
net.ipv4.ip_forward=1
">/etc/sysctl.conf
echo "已针对OVZ优化参数"
exit 0
fi

#优化最大文件打开
echo "
root soft nofile 512000
root hard nofile 512000
">>/etc/security/limits.conf
#优化TCP连接
echo "
#关闭IPV6
net.ipv6.conf.all.disable_ipv6 = 1
#开启BBR
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
#开启内核转发
net.ipv4.ip_forward=1
#优先使用ram
vm.swappiness=0
#可以分配所有物理内存
vm.overcommit_memory=1
#TCP优化
fs.file-max = 512000
net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.netdev_max_backlog = 250000
net.core.somaxconn = 4096
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_slow_start_after_idle=0
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 10000 65000
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
">/etc/sysctl.conf
sysctl -p


echo "针对kvm优化参数，已开启BBR，已修改启动时间"
read -p "输入nodeID参数继续对接V2ray" v2_node
if [ "$v2_node" != "" ]; then 
bash <(wget --no-check-certificate -qO- 'https://raw.githubusercontent.com/GouGoGoal/v2ray/master/setup.sh') $v2_node $2 $3
fi
