## DNS 라운드로빈
- DNS 라운드 로빈은 DNS를 이용해 부하를 분산하는 방법이다.
- DNS 서버는 동일한 이름으로 여러 레코드를 등록시키면 처리를 분산시킬 수 있다.
- 문제점
    - 서버의 수 만큼 글로벌 주소가 필요하다.
    - 균등하게 분산되는 것은 아니다
        - 모바일 사이트 등에서 문제가 되는 경우가 있다.
            - 모바일은 캐리어 게이트웨이라는 프록시 서버를 경유한다.
            - 프록시에서는 이름 변환 결과가 일정시간 캐싱되므로
            - 같은 프록시 서버를 경유하는 접속은 항상 같은 서버로 전달된다.
        - PC 웹 브라우저에서도 DNS 질의 결과를 캐싱하기 떄문에
            - 균등하게 분산되지 않는다.
        -  DNS의 TTL을 짧게 설정해서 어느 정도 개선할 수 있지만
            - 반드시 TTL을 따라 캐시를 해제하는 것이 아니므로 주의한다.
    - 서버가 다운되어도 감지하지 못한다.
        - DNS 분산은 리얼 서버의 부하나 접속 수 등의 상황에 따라 질의를 제어할 수 없다.-
    - DNS 라운드 로빈은 부하를 분산하기 위한 방법이지 다중화하는 방법은 아니므로
      - 다른 소프트웨어와 조합해서 헬스체크나 장애 극복을 마련할 필요가 있다.

## DNS 라운드로빈의 다중화 구성
- 다중화 구성이 필요한 경우 VIP를 이용한다.
    - 웹 서버에 VIP를 붙여두고, 한 쪽이 정지하면 다른 한쪽으로 VIP를 인계한다.
      - ip 주소를 인계하는 원리
        - LAN에서는 IP가 아닌 NIC에 고정적으로 할당 된 MAC을 사용해서 통신한다.
        - 한번 얻은 MAC주소는 ARP테이블에 저장해 일정시간 캐싱한다.
        - 따라서 테이블이 갱신 될 동안, IP가 바뀌어도 통신을 할 수 없다.
        - 즉, IP를 인계하기 위해서는 다른 서버의 ARP테이블을 갱신해주어야 하는데
            - 그 방법으로 Gratuitous APR가 있다.
            - 이 것은 APR와 반대로 내 주소와 MAC 주소는 이것이다 라고 다른 서버에 통지하기 위해 사용된다.
            - `send_arp $IP $MAC 255.255.255.255 FFFFFFF`
    - 수시로 VIP에게 Ping검사를 실시(L4)하고, curl을 이용해 헬스체크 페이지를 확인한다(L7)
- 최종적으로는 이러한 번거로운 작업 없이 로드밸런서를 도입을 하면 이러한 문제를 해결할 수 있다.

## L4와 L7 LB
- L4
    - TCP 헤더 등의 프로토콜 내용을 분석해 분산 시킬곳을 결정한다.
    - L4에서 클라이언트가 통신하는 곳은 리얼 서버다.
    - L4 모드
        - NAT
          - 클라이언트로부터 도착한 패킷의 src를 리얼 서버로 변경해서 전달한다.
        - DSR
          - IP주소는 변경되지 않는다.
          - 응답 패킷에 대해 IP주소를 되돌릴 필요가 없으므로, 리얼서버는 L4를 경유하지 않고 응답할 수 있다.
          - 다만, 패킷이 그대로 도달하므로, 리얼 서버가 글로벌 주소를 처리할 수 있어야 한다.
              - 가장 손쉬운 설정 방법으로는 리얼 서버의 루프백 인터페이스에 VIP를 할당한다.
              - 그 외로는  netfilter 기능을 이용해 가상 서버를 향한 패킷을
                  - 리얼 서버 자신을 향한 것 처럼 목적지 주소를 변경하는 DNAT 방법도 있다.
- L7
    - L7계층의 내부까지 분석해 분산 시킬 곳을 결정한다.
    - L7에서는 로드밸런서와 클라이언트가 TCP 세션을 전개한다.
        - 즉, 하나의 접속에 대해서 클라이언트 <-> 로드밸런서 와 로드밸런서 <-> 리얼서버 두 TCP 세션이 전개된다.
- 두 스위치의 특징을 단적으로 정리하면
    - 유연한 설정을 하고자 한다면 L7
    - 성능을 추구한다면 L4

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