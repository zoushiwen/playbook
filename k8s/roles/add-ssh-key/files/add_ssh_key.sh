#!/usr/bin/env bash



authorized_keys='/root/.ssh/authorized_keys'

function init() {

mkdir -p /root/.ssh
# 导入ssh key 密钥
## 公司环境 开启root登陆
SSH_CONTENT=$(grep 'PermitRootLogin yes' /etc/ssh/sshd_config)
if [ -z "${SSH_CONTENT}" ];then
    sed -i "s/PermitRootLogin no/#PermitRootLogin yes/g" /etc/ssh/sshd_config
    systemctl restart sshd
    echo "root has been launched."
fi
}

init