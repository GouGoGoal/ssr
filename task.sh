#!/bin/bash


sed -i '/.*error_log.*/d' /etc/nginx/conf.d/default.conf

#让nginx不输出日志
if [ ! `cat /etc/nginx/nginx.conf|grep 'access_log /dev/null'` ];then
sed  -i '/.*conf.d.*/ a\access_log /dev/null;\nerror_log /dev/null;' /etc/nginx/nginx.conf 
fi