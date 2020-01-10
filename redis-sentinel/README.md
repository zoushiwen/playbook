

### 1、安装 Redis-sentinel

~~~
1、修改配置文件 config
[root@q12471v redis-sentinel]# vim config
[redis-sentinel-master]
10.202.252.14               ## 必须为ip，redis sentinel 集群用ip通信

[redis-sentinel-slave]
10.202.146.155              ## 必须为ip，redis sentinel 集群用ip通信
10.202.254.171              ## 必须为ip，redis sentinel 集群用ip通信

[all:vars]
### redis Sentinel ###
redisPort = 6379            ## redis 监听端口
#requirepass = true         ## 是否开启redis 密码认证
#redisPassword = test123    ## 开启redis密码认证之后，设置redis密码

2、部署 redis sentinel
[root@q12471v redis-sentinel]# ansible-playbook -i config deploy.yml

3、检查 redis 主从信息
[root@q12471v redis-sentinel]# redis-cli -h 10.202.252.14
10.202.252.14:6379> info replication
# Replication
role:master
connected_slaves:2
slave0:ip=10.202.146.155,port=6379,state=online,offset=44234,lag=0
slave1:ip=10.202.254.171,port=6379,state=online,offset=44093,lag=1
master_repl_offset:44234
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:2
repl_backlog_histlen:44233

4、查看 Sentinel 信息
[root@q12471v redis-sentinel]# redis-cli -p 26379
127.0.0.1:26379> info Sentinel
# Sentinel
sentinel_masters:1
sentinel_tilt:0
sentinel_running_scripts:0
sentinel_scripts_queue_length:0
sentinel_simulate_failure_flags:0
master0:name=mymaster,status=ok,address=10.202.252.14:6379,slaves=2,sentinels=3

5、卸载 redis 集群
[root@q12471v redis-sentinel]# ansible-playbook -i config delete.yml

~~~

### 2、测试

2.1、主从节点数据同步测试
~~~
主节点
[root@q12471v redis-sentinel]# redis-cli -h 10.202.252.14
10.202.252.14:6379> set name zoujiangtao
OK

从节点
[root@q14913v zoujiangtao]# redis-cli -h 10.202.254.171
10.202.254.171:6379> get name
"zoujiangtao"
~~~

2.2 从节点为只读节点
~~~
[root@q14913v zoujiangtao]# redis-cli -h 10.202.254.171
10.202.254.171:6379> set age 26
(error) READONLY You can't write against a read only slave.
10.202.254.171:6379>
~~~

2.3 停止master节点

~~~
停止master节点
[root@q12471v redis-sentinel]# systemctl stop redis

可以看到 master 已经换成了 10.202.146.155
[root@q12471v redis-sentinel]# redis-cli -h 10.202.252.14 -p 26379
10.202.252.14:26379> info Sentinel
# Sentinel
sentinel_masters:1
sentinel_tilt:0
sentinel_running_scripts:0
sentinel_scripts_queue_length:0
sentinel_simulate_failure_flags:0
master0:name=mymaster,status=ok,address=10.202.146.155:6379,slaves=2,sentinels=3

~~~

在k8s上搭建Redis sentinel完全没有意义，经过测试，当master节点宕机后，sentinel选择新的节点当主节点，当原master恢复后，此时无法再次成为集群节点。
因为在物理机上部署时，sentinel探测以及更改配置文件都是以IP的形式，集群复制也是以IP的形式，但是在容器中，虽然采用的StatefulSet的Headless Service来建立的主从，但是主从建立后，master、slave、sentinel记录还是解析后的IP，但是pod的IP每次重启都会改变，所有sentinel无法识别宕机后又重新启动的master节点，所以一直无法加入集群，虽然可以通过固定podIP或者使用NodePort的方式来固定，或者通过sentinel获取当前master的IP来修改配置文件，但是个人觉得也是没有必要的，sentinel实现的是高可用Redis主从，检测Redis
Master的状态，进行主从切换等操作，但是在k8s中，无论是dc或者ss，都会保证pod以期望的值进行运行，再加上k8s自带的活性检测，当端口不可用或者服务不可用时会自动重启pod或者pod的中的服务，所以当在k8s中建立了Redis主从同步后，相当于已经成为了高可用状态，并且sentinel进行主从切换的时间不一定有k8s重建pod的时间快，所以个人认为在k8s上搭建sentinel没有意义


**参考文件**
https://redis.io/topics/sentinel