#!/bin/bash

#------------------------------------------
# description:  MySQL backup shell script
#------------------------------------------

USER="root"
PASSWORD=""
DATABASE="db1 db2 db3"
DBHOST="127.0.0.1"
MAIL="xx@xx.com"
BACKUP_DIR=/data/backup/       #备份文件存储路径
LOGFILE=/data/backup/mysql.log #日志文件路径

DATE=$(date +%Y%m%d-%H%M) #用日期格式作为文件名
OPTIONS="-h$DBHOST -u$USER -p$PASSWORD"
# OPTIONS="-h$DBHOST -u$USER -p$PASSWORD --set-gtid-purged=OFF $DATABASE"

#备份目录是否存在，否则创建该目录
if [ ! -d ${BACKUP_DIR} ]; then
    mkdir -p "${BACKUP_DIR}"
fi

#写日志
echo "--------------------" >$LOGFILE
echo "BACKUP DATE:" $(date +"%y-%m-%d %H:%M:%S") >>$LOGFILE
echo "-------------------" >>$LOGFILE

#切换至备份目录
cd ${BACKUP_DIR}
for i in ${DATABASE}; do
    /usr/local/mysql/bin/mysqldump $OPTIONS $i >${i}-${DATE}.sql
    #判断数据库备份是否成功
    if [[ $? == 0 ]]; then
        tar czvf ${i}-${DATE}.sql.tar.gz ${i}-${DATE}.sql >>$LOGFILE 2>&1
        echo "[$i] Backup Successful!" >>$LOGFILE
        rm -f ${i}-${DATE}.sql #删除原始备份文件,只需保留备份压缩包
        #把压缩包文件备份到其他机器上。
        #scp ${i}-${DATE}.sql.tar.gz root@172.17.3.35:/home/mysql_backup/ >> $LOGFILE  2>&1
    else
        echo "Database Backup Fail!" >>$LOGFILE
        #备份失败后向管理者发送邮件提醒
        #mail -s "database:$DATABASE Backup Fail!" $MAIL
    fi
done
echo "Backup Process Done"
#删除5天以上的备份文件
find ${BACKUP_DIR} -type f -mtime +5 -name "*.tar.gz" -exec rm -f {} \;
