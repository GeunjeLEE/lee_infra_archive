
# 구성
## 구성도

## TODO

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

## TODO
- package manager와 compile는 언제 어느 상황에서 적합할까?
- 여러대 설치해야할 상황이라면
  - OS image를 활용하는게 적합할까?
    - 기본 설치 작업은 한번만 이루어지고, 이후는 Image를 이용하여 배포하는게 편하지 않을까