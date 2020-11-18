#!/bin/bash

if [ "`id -u`" != 0 ];then
	echo 'SB：请使用root用户执行脚本'
	exit
fi
if [ ! -f "/etc/redhat-release" ];then
	apt install -y python3 python3-pip git libsodium-dev vim curl libssl-dev swig ntp
else
	yum install -y python3 python3-pip git curl openssl-devel libffi libffi-dev ntp
	systemctl stop firewalld
	systemctl disable firewalld
	setenforce 0
	echo 'SELINUX=disabled'>/etc/selinux/config
fi
pip3 install --upgrade setuptools 
pip3 install cymysql requests pyOpenSSL ndg-httpsclient pyasn1 pycparser pycryptodome idna speedtest-cli

rm -rf /tmp/ssr
git clone -b manyuser https://github.com/GouGoGoal/ssr /tmp/ssr
cd /tmp/ssr
#先循环一次，将带有-的参数进行配置
for i in $*
do
	if [ "${i:0:1}" == '-' ];then 
		i=${i:1}
		A=`echo $i|awk -F '=' '{print $1}'`
		case $A in 
		#开BBR以及内核参数优化
		bbr)
			curl 'https://raw.githubusercontent.com/GouGoGoal/SHELL/master/sysctl.sh'|bash
			;;
		#自定义服务名
		conf)
			B=`echo $i|awk -F '=' '{print $2}'`
			rm -rf /root/$B
			mv /tmp/ssr /root/$B
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
			wget -N --no-check-certificate -P /etc/nginx/tls https://raw.githubusercontent.com/GouGoGoal/v2ray/soga/full_chain.pem
			wget -N --no-check-certificate -P /etc/nginx/tls https://raw.githubusercontent.com/GouGoGoal/v2ray/soga/private.key
			if [ ! "`grep /etc/nginx/tls /etc/crontab`" ];then
				echo "#定时从github上更新tls证书
50 5 * * 1 root wget -N --no-check-certificate -P /etc/nginx/tls https://raw.githubusercontent.com/GouGoGoal/v2ray/soga/full_chain.pem 
50 5 * * 1 root wget -N --no-check-certificate -P /etc/nginx/tls https://raw.githubusercontent.com/GouGoGoal/v2ray/soga/private.key">>/etc/crontab
			fi
			systemctl enable nginx
			systemctl restart nginx
			;;
		#设置探针监控
		state)
			B=`echo $i|awk -F '=' '{print $2}'`
			sed -i "s|^USER.*|USER = \"$B\"|g" state.py
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
			if [ ! "`grep task.sh /etc/crontab`" ];then
				echo '
#每天05:55执行task
55 5 * * * root curl -k https://raw.githubusercontent.com/GouGoGoal/ssr/manyuser/task.sh|bash
#每天05:55清理日志日志
55 5 * * * root find /var/ -name "*.log.*" -exec rm -rf {} \;
#每天06:00点重启
0 6 * * * root init 6'>>/etc/crontab
			fi
			;;
		esac
	fi
done

#如果没有指定-conf，则默认为systemctl status ssr
if [ ! "$conf" ];then 
	rm -rf /root/ssr
	mv /tmp/ssr /root/ssr
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
echo '部署完毕'





