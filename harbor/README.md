---

### Description

ansible playbook 一键安装 harbor 服务


### 安装 harbor

~~~
1、修改配置文件 vim config
[k8s-masters]
192.168.0.1
192.168.0.2
192.168.0.3


[all:vars]
### harbor ###
HARBOR_VERSION = "v1.7.6"
NEW_INSTALL="yes"
HARBOR_DIR="/data/harbor"
HARBOR_PASSWORD = "Harbor12345"
HARBOR_PORT = 10080
HARBOR_OFFLINE_URL = "https://storage.googleapis.com/harbor-releases/harbor-offline-installer-${HARBOR_VERSION}.tgz

2、安装 harbor
[root@q12469v axion-harbor]# ansible-playbook -i config playbooks/deploy.yml

~~~