#!/bin/bash

redis_ver=
redis_install_dir=


tar xzf redis-${redis_ver}.tar.gz
cd redis-${redis_ver}

make -j ${nproc}
if [ -f "src/redis-server" ]; then
  mkdir -p ${redis_install_dir}/{bin,etc,var}
  /bin/cp src/{redis-benchmark,redis-check-aof,redis-check-rdb,redis-cli,redis-sentinel,redis-server} ${redis_install_dir}/bin/
  /bin/cp redis.conf ${redis_install_dir}/etc/
  ln -s ${redis_install_dir}/bin/* /usr/local/bin/
  sed -i 's@pidfile.*@pidfile /var/run/redis/redis.pid@' ${redis_install_dir}/etc/redis.conf
  sed -i "s@logfile.*@logfile ${redis_install_dir}/var/redis.log@" ${redis_install_dir}/etc/redis.conf
  sed -i "s@^dir.*@dir ${redis_install_dir}/var@" ${redis_install_dir}/etc/redis.conf
  sed -i 's@daemonize no@daemonize yes@' ${redis_install_dir}/etc/redis.conf
  #sed -i "s@^# bind 127.0.0.1@bind 127.0.0.1@" ${redis_install_dir}/etc/redis.conf
  sed -i "s@^# cluster-enabled yes@cluster-enabled yes@" ${redis_install_dir}/etc/redis.conf
  sed -i "s@^# cluster-config-file nodes-6379.conf@cluster-config-file nodes-6379.conf@" ${redis_install_dir}/etc/redis.conf
  sed -i "s@^# cluster-node-timeout 5000@cluster-node-timeout 5000@" ${redis_install_dir}/etc/redis.conf
  sed -i "s@^# cluster-slave-validity-factor 10@cluster-slave-validity-factor 10@" ${redis_install_dir}/etc/redis.conf
  sed -i "s@^# cluster-migration-barrier 1@cluster-migration-barrier 1@" ${redis_install_dir}/etc/redis.conf
  sed -i "s@^# cluster-require-full-coverage yes@cluster-require-full-coverage yes@" ${redis_install_dir}/etc/redis.conf
  sed -i "s@^# cluster-slave-no-failover no@cluster-slave-no-failover no@" ${redis_install_dir}/etc/redis.conf
  redis_maxmemory=`expr $Mem / 8`000000
  [ -z "`grep ^maxmemory ${redis_install_dir}/etc/redis.conf`" ] && sed -i "s@maxmemory <bytes>@maxmemory <bytes>\nmaxmemory `expr $Mem / 8`000000@" ${redis_install_dir}/etc/redis.conf
  echo "Redis-server installed successfully!"

  rm -rf redis-${redis_ver}
  id -u redis >/dev/null 2>&1
  [ $? -ne 0 ] && useradd -M -s /sbin/nologin redis
  chown -R redis:redis ${redis_install_dir}/{var,etc}

  if [ -e /bin/systemctl ]; then
    /bin/cp ../init.d/redis-server.service /lib/systemd/system/
    sed -i "s@/usr/local/redis@${redis_install_dir}@g" /lib/systemd/system/redis-server.service
    systemctl enable redis-server
  else
    /bin/cp ../init.d/Redis-server-init /etc/init.d/redis-server
    sed -i "s@/usr/local/redis@${redis_install_dir}@g" /etc/init.d/redis-server
    [ "${PM}" == 'yum' ] && { cc start-stop-daemon.c -o /sbin/start-stop-daemon; chkconfig --add redis-server; chkconfig redis-server on; }
    [ "${PM}" == 'apt-get' ] && update-rc.d redis-server defaults
  fi
  #[ -z "`grep 'vm.overcommit_memory' /etc/sysctl.conf`" ] && echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf
  #sysctl -p
  service redis-server start
else
  rm -rf ${redis_install_dir}
  echo "Redis-server install failed, Please contact the author!" && lsb_release -a
  kill -9 $$
fi


