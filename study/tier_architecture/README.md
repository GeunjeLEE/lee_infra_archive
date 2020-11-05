
# 구성

## 구성도(3 tier architecture)
<img width="1210" alt="KakaoTalk_20201102_215230796" src="https://user-images.githubusercontent.com/19552819/97870114-d5b88f00-1d55-11eb-862a-d3420327864c.png">

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

## 추가
- LB
  - 기본적으로
  - DSR
    - 보통 서비스에서는 Inbound traffic 대비 Outbound traffic이 월등히 높다.
      - Outbound traffic을 SLB에서 모두 수용하게 될 경우 리소스 소모가 커질 수 밖에 없다.
        - 그래서 Outbound traffic을 서버가 SLB에 전달하지 않고 
          - 직접 클라이언트에게 전달해 SLB의 리소스 소모 방지를 위해 사용하는 구성이 DSR(Direct Server Return) 구성이다.
    - 클라이언트의 Request를 서버로 전달함에 있어 어떤 헤더를 이용하는지에 따라 L2/L3 DSR로 구분하게 된다.
  - L2DSR
    - L2 Layer 헤더인 MAC 주소 변경을 통해 클라이언트의 Request가 전달된다.
    - MAC 주소 변경을 위해 서버와 ADC(?) 모두 동일한 Broadcast 도메인에 포함되어야 했고, 그로인한 물리적 회선, 위치 등의 한계성이 있다.
  - L3DSR(DSR 방식에서 기존 L2 Layer의 DSR 방식의 한계를 개선하기 위해 사용)
    - IP헤더를 변조하여 서버에 Request를 전달하는 구성이다.
    - L3DSR 구성은 IP 헤더중 어떠한것을 이용하는지에 따라 IP Tunnel기반과 TOS(DSCP) 기반으로 구분된다.
    - L3DSR의 경우 SLB에서 IP 주소 변경을 통해 클라이언트의 Request가 서버로 전달되기 때문에 L2DSR에서의 물리적인 한계성을 극복 할 수 있다.
      - 이를 이용해 서로 다른 곳에 위치한 IDC라도 L3DSR 구성을 통해 Load Balancing 동작이 가능하도록 할 수 있다.
        - A-장비는 A-IDC에 B-장비는 B-IDC에?
    - LB장비에서는 VIP에 바인딩된 Real Server의 IP정보를 갖고 있고 IP헤더의 DIP를 변조 후 Real Server로 전달한다.
      - L2에서는 IP가 아니라 MAC을 변조 후 Real Server로 전달한다. 이 부분이 L2와 L3의 차이점
      - Real Server에서는 DIP가 VIP으로 들어온 패킷을 자신의 IP가 아니라고 판단하고 버리게 되므로 서버의 lo:0 인터페이스에 VIP를 설정하여 사용한다.
- DB
- 네트워크 구성
- 백업
- 재해복구(DR?)
