#!/bin/bash
BLOCKED_LOG_DIR="/var/log/ssh_blocked_ips"
mkdir -p $BLOCKED_LOG_DIR

DATE=$(date +"+%Y-%m-%d_%H:%M:%S")
BLOCKED_FILE="${BLOCKED_LOG_DIR}/blocked_ips.log"

# SSHの失敗したログイン試行を取得
# 6秒にしているのは5秒ごとに検知しているので取りこぼしを防ぐため
FAILED_LOGINS=$(journalctl -u ssh --since "6 second ago" | grep "maximum authentication attempts exceeded\|Invalid user" | awk '{for(i=1;i<=NF;i++) if ($i ~ /[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/) print $i}' | uniq)

# 各IPアドレスについて処理
for IP in $FAILED_LOGINS; do
    if ! ufw status | grep -q "$IP"; then
        ufw deny from $IP
        echo "$(date) Blocked IP: $IP" >> $BLOCKED_FILE
    fi
done

