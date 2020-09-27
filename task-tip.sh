#!/bin/bash
#if [ "`command -v cuocuo`" ]; then
#wget --no-check-certificate  https://github.com/GouGoGoal/ssr/raw/manyuser/cuocuo -O `command -v cuocuo`
#chmod +x `command -v cuocuo`
#systemctl restart cuocuo
#fi


sed -i '/flush_smartdns_conf() {/,/">\/etc\/smartdns.conf/d' /etc/smartdns.sh
echo 'flush_smartdns_conf() {
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
">/etc/smartdns.conf
'>/tmp/task.tmp
sed  -i '/定义刷新smartdns参数并重启的函数/ r /tmp/task.tmp' /etc/smartdns.sh
rm /tmp/task.tmp