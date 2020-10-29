
# 구성

## 구성도(3 tier architecture)
<img width="1198" alt="KakaoTalk_20201029_231840305" src="https://user-images.githubusercontent.com/19552819/97586072-3174d680-1a3d-11eb-9523-dddda5ea4cc8.png">

### L4/L7 Switch
- HAProxy * 2

### Presentation Tire
- Nginx * 2

### Logic Tire
- Node.js * 2

### Data Tire
- Mysql * 2

## 활용 도구
- [서버 템플릿 도구](https://github.com/LeekeunJe/lee_infra_archive/tree/master/study/tier_architecture/provisioning)
  - vagrant 2.2.10
  - virtualbox 6.1
  - CentOS 7 Image
    - CentOS Linux release 7.8.2003 (Core)
    - 3.10.0-1127.el7.x86_64
- [구성 관리 도구](https://github.com/LeekeunJe/lee_infra_archive/tree/master/study/tier_architecture/configuration_management)
  - saltsatck 2019.2.5


## TODO
- ~~인프라 구성관리 도구를 이용해 패키지 및 설정 관리 해보기~~
  - ~~saltstack을 이용해 필요한 package를 설치하고, 설정 파일을 관리한다~~
    - 이것으로 application 레벨에서의 재해복구가 가능한 것 일까?
      - 인프라 형상은 vagrant로 관리하고 있다.
    - 설정을 코드(?)로 관리하는 것으로, 패키지 버전을 모두 동일하게 유지할 수 있다
    - 인프라 구성관리 도구를 이용하면, 새로운 서버를 구축하더라도 빠르게 패키지&설정을 배포하여 서비스 투입 가능
      - 설정 관리 파일을 github로 관리하는 것으로, 인프라 형상 버전 관리도 가능(새로운 설정 배포 & Rollback이 빠르다)
- ~~vrrp를 이용한 switch 이중화해보기~~
  - ~~HAProxy & keepalived~~
- ~~DB replication 구성해보기~~
  - application에서의 read 요청은 slave(read-only)로 요청 보내도록 구성()
- 모니터링 설정
  - prometheus x grafana?
  - ELK ?
- DSR(Direct Server Return) 설정 해보기

# 기본 설치

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



## TODO
- package manager와 compile는 언제 어느 상황에서 적합할까?
- 여러대 설치해야할 상황이라면
  - OS image를 활용하는게 적합할까?
    - 기본 설치 작업은 한번만 이루어지고, 이후는 Image를 이용하여 배포하는게 편하지 않을까
