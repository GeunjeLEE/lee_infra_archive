
# 구성

## 구성도(3 tier architecture)
<img width="1217" alt="KakaoTalk_20201102_215230796" src="https://user-images.githubusercontent.com/19552819/98116251-62488600-1eeb-11eb-9f05-7da2d60f2472.png">

### LoadBalancer
- HAProxy * 2

### Presentation Tier
- Nginx * 2

### Logic Tier
- Node.js * 2

### Data Tier
- Mysql * 2

### mgmt
- Saltstack * 1

### monitoring
- Prometheus & Grafana * 1
  - 각 서버에 node_exporter

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
    - 인프라 구성관리 도구를 이용하면, 새로운 서버를 구축하더라도 빠르게 패키지&설정을 배포하여 서비스 투입이 가능하지 않을까
      - 설정 관리 파일을 github로 관리하는 것으로, 인프라 형상 버전 관리도 가능하지 않을까.(새로운 설정 배포 & Rollback이 빠르다)
- ~~vrrp를 이용한 LB 이중화해보기~~
  - ~~HAProxy & keepalived~~
- ~~DB replication 구성해보기~~
  - application에서의 read 요청은 slave(read-only)로 요청 보내도록 구성
  - 이것으로는 장애에 대한 대비가 완전하지 않다
- 모니터링 설정
  - ~~prometheus x grafana~~
    - Prometheus specializes in metrics.?
    - Prometheus는 메트릭 수집, 다양한 시스템 모니터링 및 이러한 메트릭을 기반으로 경고를 설정하는 데 사용된다.
    - Prometheus에서 polling 해온다.
      - 대상 노드에서 메트릭 전송을 하는 것이 아니다.
  - ELK
    - specializes in logs?
    - Prometheus보다 상대적으로 설치가 쉽지 않다....
    - ELK는 모든 유형의 데이터를 가져오고 이러한 데이터를 기반으로 다양한 유형의 분석을 수행하고 검색하고 시각화하는 데 사용된다.
  - The biggest difference is that ELK specializes in logs, and Prometheus specializes in metrics. Most major productions require using both ELK and Prometheus, each for its own specialty. 

#
