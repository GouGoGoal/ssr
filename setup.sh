#!/bin/bash

if [ "`id -u`" != 0 ];then
	echo 'SB：请使用root用户执行脚本'
	exit
fi
if [ ! -f "/etc/redhat-release" ];then
	apt install -y python3 python3-pip git libsodium-dev vim curl libssl-dev swig ntp
else
	yum install -y python3 python3-pip git curl openssl-devel libffi libffi-dev ntp
fi
pip3 install --upgrade setuptools 
pip3 install cymysql requests pyOpenSSL ndg-httpsclient pyasn1 pycparser pycryptodome idna speedtest-cli

cd /var
rf -f ssr
git clone -b manyuser https://github.com/GouGoGoal/ssr
cd ssr
#先循环一次，将带有-的参数进行配置
for i in $*
do
	if [ "${i:0:1}" == '-' ];then 
		i=${i:1}
		A=`echo $i|awk -F '=' '{print $1}'`
		case $A in 
		#开BBR以及内核参数优化
		bbr)
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
			;;
		#自定义服务名
		conf)
			B=`echo $i|awk -F '=' '{print $2}'`
			rm -rf /root/$B
			mv -r ssr /root/$B
			cd /root/$B
			echo "[Unit]
Description=SSR deamon
After=rc-local.service
[Service]
Type=simple
ExecStart=/usr/bin/python3 /root/$B/server.py
Restart=always
#启动频率限制，开启启动失败时尝试
#StartLimitIntervalSec=180
#StartLimitBurst=90
LimitAS=infinity
LimitRSS=infinity
LimitCORE=infinity
LimitNOFILE=999999
[Install]
WantedBy=multi-user.target">/etc/systemd/system/$B.service
			conf=$B
			;;
		#监听端口
		listen)
			B=`echo $i|awk -F '=' '{print $2}'`
			sed -i "s|^\"server\":.*|\"server\": \"$B\",|g" user-config.json
			;;
		#部署nginx实现tls加密		
		nginx)
			curl -k https://raw.githubusercontent.com/GouGoGoal/SHELL/master/Nginx/nginx.sh|bash
			echo 'user  root;
worker_processes  auto;
worker_cpu_affinity auto;
worker_rlimit_nofile 51200;
error_log  /dev/null;
pid        /var/run/nginx.pid;
events {
	use epoll;
	multi_accept on;
	worker_connections  2048;
}
stream {
	access_log off;
	error_log /dev/null;
	server {
		listen 8081 reuseport ssl;
		listen 8081 udp;
		proxy_pass 127.0.0.1:8080;
		
		ssl_certificate    /etc/nginx/tls/full_chain.pem;	
		ssl_certificate_key    /etc/nginx/tls/private.key;
		ssl_protocols       TLSv1.2 TLSv1.3;
		ssl_prefer_server_ciphers on;
		ssl_ciphers  ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
		tcp_nodelay on;
	}
}'>/etc/nginx/nginx.conf
			systemctl enable nginx
			systemctl start nginx
			echo "#定时从github上更新tls证书
50 5 * * 1 root wget -N --no-check-certificate -P /etc/nginx/tls https://raw.githubusercontent.com/GouGoGoal/v2ray/soga/full_chain.pem 
50 5 * * 1 root wget -N --no-check-certificate -P /etc/nginx/tls https://raw.githubusercontent.com/GouGoGoal/v2ray/soga/private.key">>/etc/crontab
			;;
		#设置探针监控
		state)
			B=`echo $i|awk -F '=' '{print $2}'`
			sed -i "s|^USER|USER = \"$B\"|g" state.py
			mv -f state.py /etc/state.py
			echo "[Unit]
Description=state deamon
After=rc-local.service

[Service]
Type=simple
ExecStart=/usr/bin/python3 /etc/state.py
Restart=on-failure
[Install]
WantedBy=multi-user.target">/etc/systemd/system/state.service
			systemctl enable state
			systemctl restart state
			;;
		#设置定时重启、定时清理日志等任务
		task)
			echo '
#每天05:55执行task
55 5 * * * root curl -k https://raw.githubusercontent.com/GouGoGoal/ssr/manyuser/task.sh|bash
#每天05:55清理日志日志
55 5 * * * root find /var/ -name "*.log.*" -exec rm -rf {} \;
#每天06:00点重启
0 6 * * * root init 6'>>/etc/crontab
			;;
		esac
	fi
done

#如果没有指定-conf，则默认为systemctl status ssr
if [ ! "$conf" ];then 
	rm -f /root/ssr
	mv -r /var/ssr /root/ssr
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
LimitAS=infinity
LimitRSS=infinity
LimitCORE=infinity
LimitNOFILE=999999
[Install]
WantedBy=multi-user.target">/etc/systemd/system/ssr.service
	conf=ssr
fi

#再循环一次，将不带-的参数的配置进行替换
cd /root/$conf
for i in $*
do
	if [ "${i:0:1}" == "-" ];then continue;fi
	A=`echo $i|awk -F '=' '{print $1}'`
	if [ "$A" == 'NODE_ID' -o "$A" == 'SPEEDTEST' -o "$A" == 'CLOUDSAFE' -o "$A" == 'ANTISSATTACK' -o "$A" == 'AUTOEXEC' ];then 
		sed -i "s|^$A.*|$i|g" userapiconfig.py
	else 
		B=`echo $i|awk -F '=' '{print $2}'`
		sed -i "s|^$A.*|$A='$B'|g" userapiconfig.py
	fi
done

#启动服务
systemctl daemon-reload
systemctl enable $conf
systemctl restart $conf
echo '部署完毕，等待5秒将显示服务状态'
sleep 5
systemctl status $conf





