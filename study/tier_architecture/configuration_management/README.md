# SaltStack을 이용한
SaltStack을 이용하여, 서버가 state에 정의한 상태(state)가 되도록 한다.<br>
멱등성의 성질을 가지고 있으므로, 몇 번을 배포하더라도 항상 동일한 형태가 된다.

saltstack의 grains를 이용하여 노드에 역할을 부여하고, 
정의된 state 템플릿을 배포했을때 역할에 따른 상태로 변경될 수 있도록 한다.

미대응
- DB
- nfs

#### roles 추가 설정은
```
salt 'target' cmd.run 'echo "  - new_role" >> /etc/salt/grains'
salt 'target' saltutil.refresh_grains
```

### HAproxy 배포
- 전체 배포
```
salt -G 'roles:haproxy' state.apply haproxy.deploy test=True
salt -G 'roles:haproxy' state.apply haproxy.deploy 
```

- 설정 배포
```
salt -G 'roles:haproxy' state.apply haproxy.deploy.config test=True
salt -G 'roles:haproxy' state.apply haproxy.deploy.config
```

### WEB(Nginx) 배포
- 전체 배포
```
salt -G 'roles:web' state.apply web.deploy test=True
salt -G 'roles:web' state.apply web.deploy 
```

- 설정 배포
```
salt -G 'roles:web' state.apply web.deploy.config test=True
salt -G 'roles:web' state.apply web.deploy.config
```

### WAS(Nodejs) 배포

- nodejs 초기 설치 시 선행
```
salt -G 'roles:was' state.apply was.deploy.nodejs_setup test=True
salt -G 'roles:was' state.apply was.deploy.nodejs_setup 
```
- 전체 배포
```
salt -G 'roles:was' state.apply was.deploy test=True
salt -G 'roles:was' state.apply was.deploy 
```
- app 배포
```
salt -G 'roles:was' state.apply was.deploy.deploy test=True
salt -G 'roles:was' state.apply was.deploy.deploy
```
- web app 실행
```
salt -G 'roles:was' cmd.run 'forever start /home/lee_sample_node_app/app.js'
```

### prometheus 배포
- 전체 배포
```
salt -G 'roles:monitoring' state.apply prometheus.deploy test=True
salt -G 'roles:monitoring' state.apply prometheus.deploy
```

- 설정(prometheus.yml) 배포
```
salt -G 'roles:monitoring' state.apply prometheus.deploy.config test=True
salt -G 'roles:monitoring' state.apply prometheus.deploy.config
```

### exporter 배포
```
salt -G 'roles:exporter' state.apply exporter.deploy test=True
salt -G 'roles:exporter' state.apply exporter.deploy
```

### Grafana 배포
```
salt -G 'roles:monitoring' state.apply grafana test=True
salt -G 'roles:monitoring' state.apply grafana
```

# 메뉴얼

## haproxy
```
yum install haproxy
```

## nginx

```
/etc/yum.repo.d/nginx.repo 

[nginx]
name=nginx repo
baseurl=https://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=0
enabled=1

yum install nginx -y
```

## nodejs 
```
curl -sL https://rpm.nodesource.com/setup_10.x | sudo bash -

yum install nodejs
```

## mysql

```
rpm -ivh https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
yum install mysql-community-server mysql-community-client mysql-community-libs mysql-community-common mysql-community-libs-compat
```

```
CREATE USER 'examuser'@'192.168.56.%' IDENTIFIED BY 'pwd123pwd';
GRANT ALL PRIVILEGES ON *.* TO 'examuser'@'192.168.56.%' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'examuser'@'localhost' IDENTIFIED BY 'pwd123pwd';
FLUSH PRIVILEGES;

CREATE DATABASE db_test;

CREATE TABLE BOARD (
  ID VARCHAR(50),
  TITLE VARCHAR(200),
  CONTENT VARCHAR(1000),
  WDATE DATE
);
```

## mysql replica
### Master
```
[]# vim /etc/my.cnf
```
```
# For advice on how to change settings please see
# http://dev.mysql.com/doc/refman/5.7/en/server-configuration-defaults.html

[mysqld]
#
# Remove leading # and set to the amount of RAM for the most important data
# cache in MySQL. Start at 70% of total RAM for dedicated server, else 10%.
# innodb_buffer_pool_size = 128M
#
# Remove leading # to turn on a very important data integrity option: logging
# changes to the binary log between backups.
# log_bin
#
# Remove leading # to set options mainly useful for reporting servers.
# The server defaults are faster for transactions and fast SELECTs.
# Adjust sizes as needed, experiment to find the optimal values.
# join_buffer_size = 128M
# sort_buffer_size = 2M
# read_rnd_buffer_size = 2M
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock

# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0

log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid

log-bin=mysql-bin
max_binlog_size=100M
expire_logs_days=7

server-id=1
binlog_do_db=db_test ## target replica DB name
```
```
[]# systemctl restart mysqld
```
```
[]# mysql -u root -p
mysql > GRANT REPLICATION SLAVE ON *.*  TO 'reql'@'192.168.56.%' IDENTIFIED BY 'pwd123pwd';
mysql > FLUSH PRIVILEGES;

mysql > FLUSH TABLES WITH READ LOCK;

mysql > SHOW MASTER STATUS;
+------------------+----------+--------------+------------------+-------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+------------------+----------+--------------+------------------+-------------------+
| mysql-bin.000001 |      154 | db_test      |                  |                   |
+------------------+----------+--------------+------------------+-------------------+
mysql > exit
```
```
[]# mysqldump -u root -p db_test --master-data > dump.sql
```

### Slave
```
[]# vim /etc/my.cnf
```
```
# For advice on how to change settings please see
# http://dev.mysql.com/doc/refman/5.7/en/server-configuration-defaults.html

[mysqld]
#
# Remove leading # and set to the amount of RAM for the most important data
# cache in MySQL. Start at 70% of total RAM for dedicated server, else 10%.
# innodb_buffer_pool_size = 128M
#
# Remove leading # to turn on a very important data integrity option: logging
# changes to the binary log between backups.
# log_bin
#
# Remove leading # to set options mainly useful for reporting servers.
# The server defaults are faster for transactions and fast SELECTs.
# Adjust sizes as needed, experiment to find the optimal values.
# join_buffer_size = 128M
# sort_buffer_size = 2M
# read_rnd_buffer_size = 2M
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock

# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0

log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid

relay-log=mysql-relay-bin
log-bin=mysql-bin

server-id=2
binlog_do_db=db_test
read_only
```
```
[]# scp user@ip:/path/to/dump.sql ./
```
```
[]# mysql -u root -p db_test < dump.sql

[]# mysql -u root -p 

mysql > STOP SLAVE;

mysql > CHANGE MASTER TO
MASTER_HOST='192.168.56.16',
MASTER_USER='reql' , 
MASTER_PASSWORD='pwd123pwd',
MASTER_PORT=3306,
MASTER_LOG_FILE='mysql-bin.000001',★SHOW MASTER STATUS에서 확인
MASTER_LOG_POS=154;★SHOW MASTER STATUS에서 확인

mysql > START SLAVE;

mysql > SHOW SLAVE STATUS \G;
```

### Master
```
[]# mysql -u root -p 

mysql > UNLOCK TABLES;  
```
