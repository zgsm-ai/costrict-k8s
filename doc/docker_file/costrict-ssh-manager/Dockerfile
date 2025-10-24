FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# 1. 装 ssh 与常用工具
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
        openssh-server \
        sudo \
        curl \
        wget \
        vim-tiny \
        netcat-openbsd \
        iputils-ping \
        net-tools \
 && rm -rf /var/lib/apt/lists/* \
    /var/cache/apt/archives/* \
    /usr/share/doc \
    /usr/share/man \
    /usr/share/locale \
    /var/log/* \
    /tmp/*

# 2. 准备目录与初始 host-key（会被后面入口脚本覆盖）
RUN mkdir -p /var/run/sshd /root/.ssh && \
    chmod 700 /root/.ssh && \
    ssh-keygen -A

# 3. 允许 root 登录
RUN sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

# 4. 入口脚本
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22
ENTRYPOINT ["/entrypoint.sh"]