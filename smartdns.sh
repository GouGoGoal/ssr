#!/bin/bash

#获取当前的流媒体解锁IP，若不解锁某区域的流媒体注释掉即可
twip=`ping -c1 -w1 unlock.tw.soulout.club|awk -F'[(|)]' 'NR==1{print $2}'`
hkip=`ping -c1 -w1 unlock.hk.soulout.club|awk -F'[(|)]' 'NR==1{print $2}'`
jpip=`ping -c1 -w1 unlock.jp.soulout.club|awk -F'[(|)]' 'NR==1{print $2}'` 
usip=`ping -c1 -w1 unlock.us.soulout.club|awk -F'[(|)]' 'NR==1{print $2}'` 
#cnip=`ping -c1 -w1 unlock.cn.soulout.club|awk -F'[(|)]' 'NR==1{print $2}'` 
#sgip=`ping -c1 -w1 unlock.sg.soulout.club|awk -F'[(|)]' 'NR==1{print $2}'` 

#奈飞IP，就近解锁，美国鸡就写usip
#nfip=$hkip



#若查询不到则赋值为-，即忽略
if [ "$twip" = "" ]; then twip="-"; fi
if [ "$hkip" = "" ]; then hkip="-"; fi
if [ "$jpip" = "" ]; then jpip="-"; fi
if [ "$usip" = "" ]; then usip="-"; fi
if [ "$cnip" = "" ]; then cnip="-"; fi
if [ "$sgip" = "" ]; then sgip="-"; fi
if [ "$nfip" = "" ]; then nfip="-"; fi
#释放内存，若需要开启，请将代码最下方的freeram函数注释掉
freeram() {
	#获取总共内存
	totally_ram=`free -m | awk '/Mem/ {print $2}'`
	#获取当前使用的swap量
	used_swap=`free -m | awk '/Swap/ {print $3}'`
	#如果swap=0,则退出脚本，如果总内存/swap用量小于10，即swap超过物理内存的10%
	if [ "$used_swap" -eq 0 ]; then
		exit 
	elif [ `expr $totally_ram / $used_swap` -lt 10 ]; then
		#内存释放执行的命令,重启docker之类的
		systemctl restart ssr v2ray docker
		swapoff -a && swapon -a
		echo "IP无变动，但当前RAM不足，已重启相关服务"
		exit
	fi
}

#定义刷新smartdns参数并重启的函数
flush_smartdns_conf() {
echo "
#绑定到本机
bind 127.0.0.1
#bind-tcp 127.0.0.1
#上游tcp查询，可以再添加所在地域的DNS
server-tcp 1.1.1.1:53
server-tcp 8.8.8.8:53
#台湾DNS
server-tcp 168.95.1.1:53
#香港DNS
server-tcp 202.14.67.4:53
#日本DNS
server-tcp 203.119.1.1:53
#韩国DNS
server-tcp 210.220.163.82:53
#俄罗斯DNS
server-tcp 77.88.8.8:53
#TCP查询超时60s
tcp-idle-time 60
#本地缓存条数
cache-size 1024
#域名预先获取功能
prefetch-domain yes
#过期缓存服务功能
serve-expired no
#测速模式选择，先ping，不通再tcping 80
speed-check-mode ping,tcp:80
#双栈IP优选
dualstack-ip-selection no
#dualstack-ip-selection-threshold 30
#完全不解析IPV6
#force-AAAA-SOA yes
#日志级别 error
log-level error
#日志位置
log-file /var/log/smartdns.log
log-size 128k
log-num 1
#ban掉部分域名
conf-file /etc/ban.conf
#奈飞
#address /fast.com/$nfip
address /netflix.com/$nfip
#address /netflix.net/$nfip
#address /nflxext.com/$nfip
#address /nflximg.net/$nfip
#address /nflxso.net/$nfip
address /nflxvideo.net/$nfip
#香港TVB
address /mytvsuper.com/$hkip
address /tvb.com/$hkip
#香港Viu
address /viu.com/$hkip
#台湾动画疯
address /gamer.com.tw/$twip
address /bahamut.com.tw/$twip
address /hinet.net/$twip
#台湾四季TV
address /4gtv.tv/$twip
#台湾LineTV
address /linetv.tw/$twip
#B站
address /bilibili.com/$twip
address /hdslb.com/$twip
#日本AbemaTV
address /ameba.jp/$jpip
address /abema.io/$jpip
address /akamaized.net/$jpip
#TVer
address /tver.jp/$jpip
address /amazonaws.com/$jpip
address /yahoo.co.jp/$jpip
address /brightcove.com/$jpip
#niconico
address /nicovideo.jp/$jpip
address /nimg.jp/$jpip
#hulu.jp
#address /hulu.jp/$jpip
address /hjholdings.tv/$jpip
#DAZN
address /dazn.com/$jpip
address /indazn.com/$jpip
address /app-measurement.com/$jpip
#DMM
address /dmm.com/$jpip
#PornHub
#address /pornhub.com/$jpip
#address /phncdn.com/$jpip
#美国disneynow disney+
address /disneynow.com/$usip
address /disneyplus.com/$usip
address /go.com/$usip
#美国hulu
address /hulu.com/$usip
address /huluim.com/$usip
#美国HBO
address /hbo.com/$usip
address /hbomax.com/$usip
address /hbonow.com/$usip
#美国espn+
address /espn.com/$usip
address /espn.net/$usip
address /espncdn.com/$usip
address /bamgrid.com/$usip
#美国peaacock
address /peacocktv.com/$usip
#中国腾讯视频
address /v.qq.com/$cnip
address /video.qq.com/$cnip
#中国爱奇艺
address /qiyi.comm/$cnip
address /qy.net/$cnip
address /iqiyipic.com/$cnip
">/etc/smartdns.conf
#重启服务
systemctl restart smartdns
}

if [ ! -f "/etc/smartdns.conf" ]; then 
	echo "当前无配置文件，已生成"
	flush_smartdns_conf
else
	#对比IP变化，有变化就刷新重启smartdns
	if [ "`grep $twip /etc/smartdns.conf`" == "" -o "`grep $hkip /etc/smartdns.conf`" == "" -o "`grep $jpip /etc/smartdns.conf`" == "" -o "`grep $usip /etc/smartdns.conf`" == "" -o "`grep $cnip /etc/smartdns.conf`" == "" -o "`grep $sgip /etc/smartdns.conf`" == "" ];then
		echo "IP有变化，已重新生成配置文件"
		flush_smartdns_conf
	else 
		echo "IP无变化，退出脚本"
	fi     
fi

#iptables劫持DNS，若规则经常意外丢失就取消此处注释
if [ "`iptables -t nat -nL |grep DNAT|grep -w 127.0.0.1:53`" == "" ]; then
	if [ "`systemctl status smartdns|grep running`" ];then
		iptables -t nat -A OUTPUT -p udp --dport 53 -j DNAT --to-destination 127.0.0.1:53
		#iptables -t nat -A OUTPUT -p udp --dport 53 ! -d 1.2.3.4 -j DNAT --to-destination 127.0.0.1:53
		#如果购买的流媒体解锁DNS为1.2.3.4，可以按上方命令将其排除不进行劫持
	fi
fi


#NAT小鸡解锁作服务端，请自行更改映射出来的80公网IP端口
#if [ "`iptables -t nat -nL|grep DNAT|grep -w $hkip|grep dpt:80`" == "" ]; then
#		number=`iptables -t nat -nL --line-number|grep $old_hkip|grep dpt:80|awk -F ' ' '{print $1}'|head -1`
#		if [ "$number" == "" ];then iptables -t nat -D OUTPUT $number;fi
#		iptables -t nat -A OUTPUT -p tcp -d $hkip --dport 80 -j DNAT --to-destination $hkip:10080
#fi
#NAT小鸡解锁作服务端，请自行更改映射出来的443公网IP端口
#if [ "`iptables -t nat -nL|grep DNAT|grep -w $hkip|grep dpt:443`" == "" ]; then
#		number=`iptables -t nat -nL --line-number|grep $old_hkip|grep dpt:443|awk -F ' ' '{print $1}'|head -1`
#		if [ "$number" == "" ];then iptables -t nat -D OUTPUT $number;fi
#		iptables -t nat -A OUTPUT -p tcp -d $hkip --dport 443 -j DNAT --to-destination $hkip:10443
#fi

#根据当前swap占用自动释放内存
#freeram
