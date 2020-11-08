# LB
## 기본적으로(inline mode?)
![slb](https://user-images.githubusercontent.com/19552819/98251343-f3872d80-1fbb-11eb-9140-aae796b26fe4.jpg)
- Internet → A → L3 Switch → B  → L4 Switch → C → Web Server → C → L4 Switch → B → L3 Switch → A → Internet

## DSR이면?

![dsr](https://user-images.githubusercontent.com/19552819/98251348-f41fc400-1fbb-11eb-990d-d569334cebde.jpg)

- Internet → A → L3 Switch → B → L4 Switch → B -> L3 Switch -> C → L2 Switch → D → Web Server 1 → D → L2 Switch → C → L3 Switch → Internet

### DSR에 대해서
- 보통 서비스에서는 Inbound traffic 대비 Outbound traffic이 월등히 높다.
  - Outbound traffic을 SLB에서 모두 수용하게 될 경우 리소스 소모가 커질 수 밖에 없다.
    - 그래서 Outbound traffic을 서버가 SLB에 전달하지 않고 
      - 직접 클라이언트에게 전달해 SLB의 리소스 소모 방지를 위해 사용하는 구성이 DSR(Direct Server Return) 구성이다.
        - 그렇기 때문에 기존 구성에서 L4 스위치를 옆으로 빼서 구성한 것 인가?
  - 클라이언트의 Request를 서버로 전달함에 있어 어떤 헤더를 이용하는지에 따라 L2/L3 DSR로 구분하게 된다.

### L2DSR
  - L2 Layer 헤더인 MAC 주소 변경을 통해 클라이언트의 Request가 전달된다.
  - MAC 주소 변경을 위해 서버와 ADC 모두 동일한 Broadcast 도메인에 포함되어야 했고, 그로인한 물리적회선, 위치 등의 한계성이 있다.
    - ADC는 Application Delivery Controller를 의미?

### L3DSR(DSR 방식에서 기존 L2 Layer의 DSR 방식의 한계를 개선하기 위해 사용)
  - IP헤더를 변조하여 서버에 Request를 전달하는 구성이다.
  - L3DSR 구성은 IP 헤더중 어떠한것을 이용하는지에 따라 IP Tunnel기반과 TOS(DSCP) 기반으로 구분된다.
  - L3DSR의 경우 SLB에서 IP 주소 변경을 통해 클라이언트의 Request가 서버로 전달되기 때문에 L2DSR에서의물리적인 한계성을 극복 할 수 있다.
    - 이를 이용해 다른 곳에 위치한 IDC라도 L3DSR 구성을 통해 Load Balancing 동작이 가능하도록 할수 있다.
      - A-장비는 A-IDC에 B-장비는 B-IDC에?
  - LB장비에서는 VIP에 바인딩된 Real Server의 IP정보를 갖고 있고 IP헤더의 DIP를 변조 후 Real Server로전달한다.
    - L2에서는 IP가 아니라 MAC을 변조 후 Real Server로 전달한다. 이 부분이 L2와 L3의 차이점
    - Real Server에서는 DIP가 VIP으로 들어온 패킷을 자신의 IP가 아니라고 판단하고 버리게 되므로 서버의lo:0 인터페이스에 VIP를 설정하여 사용한다.
      - DSCP 기반의 L3DSR이라면 DSCP값을 LB장비와 동일하게 하여 iptable 설정을 한다. -> 서버에서Loopback Interface까지 전달되도록
      - IP Tunnel 기반이라면 기존의 클라이언트의 요청을 Inner IP header에 그대로 보존한 뒤 
        - 덧붙여진 Outer IP header의 DIP를 보고 실제 server를 찾아 들어간다. 

# DB 이중화
## 기존
  - DB single
    - 하나의 서버로 구성하며, DB서버가 다운되면 다시 복구하기까지 서비스가 정지된다.
  - DB 복제(Replication)
    - 하나의 DB서버를 하나 더 구축하여 데이터를 복제한다.(Master <-> Slave)
      - Master서버가 다운되었을때, Slave서버의 IP를 바라보도록 설정을 변경하여 대응할 수 있다.
    - Single 구성보다는 Down Time이 줄었지만
      - 역시 장애를 인지하고, 각 App서버가 Slave 서버를 바라보도록 설정을 배포하는 시간 동안 서비스가 중단된다.
  - DB 복제 + VIP
    - 기존의 복제 구성에서 Master에 VIP를 추가하고 각 App서버는 VIP를 바라보도록 한다.
      - 장애가 발생하면 Master에 붙어있는 VIP를 Slave로 옮긴다.
        - 이것으로 App 서버의 설정을 새로 배포하지 않아도 대응이 가능하다.
    - Failover 과정에서 순단은 일어나지만, 기존의 구성보다 더 빠르게 장애를 대응할 수 있다.
      - 자동으로 Health Check + Failover를 해주는 이중화 방안이 있으면 수고를 덜 수 있다.

## 이중화 방안
  - HW 이중화
    - Shared Disk(예 : OS Cluster / RHCS)
      - Master를 Active-Standby로 구성하고, 2대의 서버는 같은 Disk(shared disk)를 바라본다.
        - 평상시는 Master(Active)를 shared disk에 연결하고 VIP를 붙여 Mysql를 서비스한다.
        - Master(Active)가 장애가 나면 Master(Standby)를 shared disk에 연결하고 VIP를 붙여 서비스한다.
          - 평상시 Master(Standby)는 Mysql를 서비스하고 있지 않다가 장애시에 Failover용도로만 사용한다.
        - 단점
          - RHCS 솔루션 구매가 필요하고, 고비용의 Shared Disk가 필요하다.
    - Disk 복제(DRBD + Corosync + Pacemaker)
      - Master를 Active-Standby로 구성하고 각각의 Disk를 바라본다.
        - Active에 기록된 데이터는 네트워크를 통해 Standby로 Disk를 복제한다. (Sync)
          - 그러므로, Network Latency에 의해 성능에 영향을 받는다.
      - 평상시는 Master(Active)에 VIP를 붙여 Mysql를 서비스한다.
      - Shared disk방식에 비해 라이센스, 고성능의 Disk 없이 사용 가능하다.
    - 공통 적으로
      - Standby는 Failover시에만 사용가능하다.
      - 백업을 위한 추가 서버가 필요하다.
      - 유지 보수 및 장애 대응이 어렵다.(OS 및 하드웨어에 대한 지식이 필요하다.)
  - Replication 이중화
    - MMM(Multi-Master Replication Manager)
      - Perl 기반의 Auto Failover Open Source
      - MMM Monitor에서 DB서버의 Health Check와 Failover를 수행한다.
      - Monitor - Agent 방식
      - 구성
        - MMM monitor
        - Master (Active) <--양방향 복제--> Master (Standby/Read-only)
# 스토리지
# 백업
# 재해복구(DR?)