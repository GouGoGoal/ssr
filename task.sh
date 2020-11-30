#!/bin/bash

sed -i "s|.*/hulu.jp/.*|address /hulu.jp/\$jpip|g" /etc/smartdns.sh
rm /etc/smartdns.conf