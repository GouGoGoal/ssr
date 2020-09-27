## 测速脚本
```
wget -qO- bench.sh | bash        纯净
bash <(wget --no-check-certificate -qO- 'https://git.io/superspeed' )
curl -fsL https://ilemonra.in/LemonBenchIntl | bash -s fast  能看到部分流媒体支持情况
```

## 一键后端安装
```
bash <(curk -k https://raw.githubusercontent.com/gougogoal/ssr/manyuser/setup.sh') 70 weburl token alihk1 [ovz]
参数1填0跳过安装ssr，进行其他初始化操作
参数2是对接地址
参数3是对接密码
参数4填0或没有第二个参数，跳过安装监控
参数5填ovz则不优化内核参数
```
## web_transfer.py 第 365行端口偏移

## 参数优化<br>
```
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

```

```
优先使用IPV6地址 
echo "precedence ::ffff:0:0/96  100" >>/etc/gai.conf
```
```
加SSH证书
mkdir /root/.ssh 
echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA5qK3fDbxZshKP3MbQo4xm1YNmTQsHcapbF8wAXJJcCgxtzujH9QuFCeQzsQ3QET2qZgG1k0GfTV6slRdrJJeI8fdwFgRc28JEhXh4rGx8MUdotJh8eVAnygWATBtet2Au5gpn3s3s44XqgnWXY+bRGJ6WoB58/3fjPG1YZIR5wh9knNxRt/9VO8YCTBqQP3z5hdPuNldx3jgIuFNhcI1qBVnQZ2czC2Zv8sHDDuiuNoaomKsg7LgbhKPnvRfEGb+yZaU/KKwbEJwbFcZkT7QiW90OhYVKT2+K8xEsUpR4ocH+SxgvFrpyKAXkSqF/Wwe32baAlzrNwucLdsS+jBk3w==">>/root/.ssh/authorized_keys;

```
