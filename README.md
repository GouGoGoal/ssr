## 测速脚本
```
wget -qO- bench.sh | bash        纯净
bash <(wget --no-check-certificate -qO- 'https://git.io/superspeed' )
curl -fsL https://ilemonra.in/LemonBenchIntl | bash -s fast  能看到部分流媒体支持情况
```

## 一键后端安装
```
bash <(curl -k https://raw.githubusercontent.com/gougogoal/ssr/manyuser/setup.sh') NODE_ID=0 WEBAPI_URL=https://www.baidu.com WEBAPI_TOKEN=password [...]
#不带-的参数与前端对接有关，分别是对接ID、对接地址、对接密码
NODE_ID=0
WEBAPI_URL=https://www.baidu.com 
WEBAPI_TOKEN=password
#更多参数请查看userapiconfig.py文件
#带-的不涉及对接信息，都是非必须参数
-conf=test #指定参数文件名，后续通过 systemctl status test 管理服务，同时服务文件夹目录改为/root/test，不填则用 systemctl status ssr 来管理，服务文件夹目录为/root/ssr
-listen=127.0.0.1 #监听端口，若用了隧道，可以把监听地址改成127.0.0.1，可以不暴露SSR端口至公网，默认是0.0.0.0
-nginx #同时安装nginx，并添加证书更新定时任务
-bbr #同时开启BBR(若内核不支持则不生效)，并优化内核参数
-state=123 #对接探针
-task #添加定时重启，定时清理日志等计划任务

```
## web_transfer.py 第 365行端口偏移

## 开启BBR以及内核参数优化<br>
```
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
加SSH密钥，实现免密登录
mkdir /root/.ssh 
echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA5qK3fDbxZshKP3MbQo4xm1YNmTQsHcapbF8wAXJJcCgxtzujH9QuFCeQzsQ3QET2qZgG1k0GfTV6slRdrJJeI8fdwFgRc28JEhXh4rGx8MUdotJh8eVAnygWATBtet2Au5gpn3s3s44XqgnWXY+bRGJ6WoB58/3fjPG1YZIR5wh9knNxRt/9VO8YCTBqQP3z5hdPuNldx3jgIuFNhcI1qBVnQZ2czC2Zv8sHDDuiuNoaomKsg7LgbhKPnvRfEGb+yZaU/KKwbEJwbFcZkT7QiW90OhYVKT2+K8xEsUpR4ocH+SxgvFrpyKAXkSqF/Wwe32baAlzrNwucLdsS+jBk3w==">>/root/.ssh/authorized_keys;

```
