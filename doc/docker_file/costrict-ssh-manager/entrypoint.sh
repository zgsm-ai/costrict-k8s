#!/bin/bash
set -e

# 1. 读取 root 密码
if [[ -f /etc/secrets/password ]]; then
    PASS=$(cat /etc/secrets/password)
    echo "root:${PASS}" | chpasswd
fi

# 2. 写入 authorized_keys
if [[ -f /etc/secrets/authorized_keys ]]; then
    cp /etc/secrets/authorized_keys /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
fi

# 3. 可选：覆盖 host-key（保持 Pod 重建指纹不变）
if [[ -d /etc/secrets/ssh_host_keys ]]; then
    cp /etc/secrets/ssh_host_keys/* /etc/ssh/
    chmod 600 /etc/ssh/ssh_host_*
fi

# 4. 启动 sshd
exec /usr/sbin/sshd -D