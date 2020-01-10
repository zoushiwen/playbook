### 安装 etcd

- etcd install on k8s

**需要 ceph rbd,可以换成nfs**
~~~
第一步
[root@q12469v etcd]# ansible-playbook -i config playbooks/etcd/deploy.yml

第二步
[root@q12469v etcd]# ansible-playbook -i config playbooks/etcd/service_start.yml

~~~