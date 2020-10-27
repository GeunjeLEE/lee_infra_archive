
# 구성

## 구성도(3 tier architecture)
<img width="1168" alt="KakaoTalk_20201028_000400107_01" src="https://user-images.githubusercontent.com/19552819/97320501-36a51a80-18b1-11eb-8a5c-86e53ddffc5c.png">

### L4/L7 Switch
- HAProxy

### Presentation Tire
- Nginx * 2

### Logic Tire
- Node.js * 2

### Data Tire
- Mysql * 1

## 활용 도구
- 서버 템플릿 도구
  - vagrant 2.2.10
  - virtualbox 6.1
  - CentOS 7 Image
    - CentOS Linux release 7.8.2003 (Core)
    - 3.10.0-1127.el7.x86_64
- 구성 관리 도구
  - saltsatck 2019.2.5


## TODO
- ~~인프라 구성관리 도구를 이용해 패키지 및 설정 관리 해보기~~
  - ~~saltstack을 이용해 필요한 package를 설치하고, 설정 파일을 관리한다~~
    - 이것으로 application 레벨에서의 재해복구가 가능한 것 일까?
      - 인프라 형상은 vagrant로 관리하고 있다.
    - 설정을 코드(?)로 관리하는 것으로, 패키지 버전을 모두 동일하게 유지할 수 있다
    - 인프라 구성관리 도구를 이용하면, 새로운 서버를 구축하더라도 빠르게 패키지&설정을 배포하여 서비스 투입 가능
      - 설정 관리 파일을 github로 관리하는 것으로, 인프라 형상 버전 관리도 가능(새로운 설정 배포 & Rollback이 빠르다)
- vrrp를 이용한 switch 이중화해보기
  - HAProxy & keepalived?
  - HAProxy 기본 vrrp 기능?
- DB replication 구성해보기
  - application에서 read 요청이 발생할 경우, read-only(slave)로 요청 보내도록 구성
    - application에서 설정이 필요?
- 모니터링 설정
  - prometheus x grafana?
  - ELK ?

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
