#!/bin/bash
cd /home/web/soft/GuangGao_Client

tail -n 2000000 nohup.out > 200w.out && \
cat /dev/null > nohup.out



cat > /etc/logrotate.d/GuangGaoClient << EOF

/home/web/soft/GuangGao_Client/nohup.out {
  copytruncate
  daily
  rotate 5
  compress
  missingok
  size 200M
}
EOF

logrotate -d -f /etc/logrotate.d/GuangGaoClient
