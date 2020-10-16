#!/bin/bash

cudir=/data/wwwlogs/
cd $cudir
cudate=$(date +"%F" -d "-10 days")

find -newermt "$cudate" -type f -name "*.gz" > scpfilelist
true > scplog

for i in $(cat scpfilelist); do
    scp $i 192.168.254.152:/opt/cmslog/cms/ &>/dev/null
    echo "$i" >> scplog
done