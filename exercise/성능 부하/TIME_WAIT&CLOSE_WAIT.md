# TIME_WAIT 소켓이 서비스에 미치는 영향
참고: 
- https://tech.kakao.com/2016/04/21/closewait-timewait/
- https://jihooyim1.gitbooks.io/linuxbasic/content/contents/07.html

## TCP 통신과정
TCP에서 최초의 연결을 맺게 되는 과정을 3 way handshake라고한다.

- Client -> Server : SYN
    - 접속 요청 Client가 연결 요청 메시지 전송 (SYN)
    - 송신자가 최초로 데이터를 전송할 때 Sequence Number를 임의의 랜덤 숫자로 지정하고 SYN 플래그 비트를 1로 설정한 세그먼트를 전송한다.

- Server -> Client: SYN + ACK
    - 접속 요청을 받은 프로세스 Server가 요청을 수락했으며, 접속 요청 프로세스인 Client도 소켓을 열어 달라는 메시지 전송 (SYN + ACK)
    - 수신자는 Acknowledgement Number 필드를 (Sequence Number + 1)로 지정하고, 
       SYN과 ACK 플래그 비트를 1로 설정한 세그먼트를 전송한다.

- Client -> Server : ACK
    - 마지막으로 접속 요청 프로세스 Client가 수락 확인을 보내 연결을 맺음 (ACK)
    - 이때, 전송할 데이터가 있으면 이 단계에서 데이터를 전송할 수 있다.

이후 데이터 요청/응답이 이루어지고, 통신을 모두 마친 이후에는 연결을 종료한다<br>
이 과정을 4 way handshake라고 한다.<br>
(여기서는 연결을 끊기위해 요청을 보내는 곳이 Active)

- Active -> Passive: FIN
    - Active가 연결을 종료하겠다는 FIN 플래그를 전송
    - Passive가 FIN 플래그로 응답하기 전까지 연결을 계속 유지
    - Active의 소켓 상태는 FIN_WAIT_1로 변경

- Passive -> Active: ACK
    - Passive의 소켓 상태는 CLOSE_WAIT로 변경
    - Passive는 Acknowledgement Number 필드를 (Sequence Number + 1)로 지정하고, ACK 플래그 비트를 1로 설정한 세그먼트를 전송한다.
      - 그와 동시에, 해당 포트에 연결되어있는 AP에게 Close()를 요청한다.
    - ACK를 받은 Active는 FIN_WAIT_2로 변경되며, Passive의 FIN을 기다린다.
    - Passive에서 전송할 것이 있으면 계속 전송(이때 서버의 소켓은 Close_Wait)

- Passive -> Active: FIN
    - Passive가 통신이 끝났으면 연결 종료 요청에 합의한다는 의미로 Active에게 FIN 플래그를 전송
    - Passive의 소켓은 Last_ack가 된다.
    
- Active -> Passive: ACK
    - FIN을 받은 Active는 Passive에게 ACK을 전송한다.
    - Active의 소켓은 TIME_WAIT가 되고, 일정 시간이 지나면 CLOSED가 된다.
    - ACK을 받은 Passive도 소켓를 CLOSED한다.

## TIME_WAIT의 문제점
먼저 close 요청을 보내는 쪽이 active closer라고 하고 그 반대를 passive closer라고 한다.<br>
먼저 close요청을 보내는 쪽에 TIME_WAIT 소켓이 생성된다.<br>

잦은 TCP 요청/종료에 의해서 TIME_WAIT 소켓이 많아지면 먼저 로컬 포트 고갈로 인해<br>
커넥션 타임아웃이 발생한다.

로컬 포트는 리눅스 커널 parameter중 net.ipv4.ip_local_port_range에 정의되어있는데<br>
외부와 통신하기 위해 소켓 생성을 요청할때 해당 소켓이 사용하게 될 로컬 포트는<br>
net.ipv4.ip_local_port_range의 범위 중 하나의 값이 사용된다.

이때, TIME_WAIT 소켓이 많아 net.ipv4.ip_local_port_range의 범위만큼의 소켓이 존재하게 되면<br>
더 이상 사용할 수 있는 로컬 포트(고갈)가 없어 외부와 통신을 하지 못하게 되고, 이로 인해 APP에서는 타임아웃이 발생할 수 있다.

또한 잦은 TCP 요청/종료로 인해 응답속도 저하도 일어날 수 있다.<br>
통신량이 많을 때 TCP 요청/종료를 반복한다면 그만큼 많은 양의 3 way handshake가 필요하게 되고<br>
이는 전체적인 서비스의 응답속도 저하의 원인이 될 수 있다.

## TIME_WAIT는 왜 필요할까
만일 TIME_WAIT가 짧다면, 두 가지 문제가 발생한다.

- 지연 패킷이 발생할 경우
  - 이미 다른 연결로 진행되었다면 지연 패킷이 뒤늦게 도달해 문제가 발생한다.
  -  매우 드문 경우이긴 하나 때마침 SEQ까지 동일하다면 잘못된 데이타를 처리하게 되고 데이타 무결성 문제가 발생한다.
- 원격 종단의 연결이 닫혔는지 확인해야 할 경우
  - 마지막 ACK 유실시 상대방은 LAST_ACK 상태에 빠지게 되고 새로운 SYN 패킷 전달시 RST를 리턴한다.
  - 즉, 새로운 연결은 오류를 내며 실패한다.
  - 이미 연결을 시도한 상태이기 때문에 상대방에게 접속 오류 메시지가 출력될 것이다.

따라서, 반드시 TIME_WAIT가 일정 시간 남아서, 패킷의 오동작을 막아야한다.<br>
RFC 793 에는 TIME_WAIT을 2 MSL(Maximum Segment Lifetime)로 규정했으며 CentOS 6에서는 60초 동안 유지된다.

틀린 정보: net.ipv4.tcp_fin_timeout 을 설정하면 TIME_WAIT 타임아웃을 변경할 수 있다.<br>
TIME_WAIT의 타임아웃 정보는 커널 헤더 include/net/tcp.h 에 하드 코딩 되어 있으며 변경이 불가능하다.

```
#define TCP_TIMEWAIT_LEN (60*HZ) /* how long to wait to destroy TIME-WAIT
                                  * state, about 60 seconds     */
```

## 어떻게 대처해야할까? TIME_WAIT에 의한 성능 저하를 어떻게 극복해야할까?
로컬 포트 고갈에 대응할 수 있는 방법 중 하나는 커널 파라미터를 이용하는 방법이다.<br>
TIME_WAIT 소켓을 처리하는 커널 파라미터 중 net.ipv4.tcp_tw_reuse는 외부로 요청할 때 TIME_WAIT 소켓을 재사용할 수 있게 해준다.<br>

```
$ echo 1 > /proc/sys/net/ipv4/tcp_tw_reuse
$ sysctl net.ipv4.tcp_tw_reuse
net.ipv4.tcp_tw_reuse = 1
```

net.ipv4.tcp_tw_reuse를 활성화하면 새로운 타임스탬프가 기존 커넥션의 가장 최근 타임스탬프보다도 큰 경우<br>
TIME_WAIT 상태인 커넥션을 재사용하게 된다.<br>
tcp_tw_reuse가 비활성화 상태라면 매 번 비어 있는 포트를 스캔하게 되지만, 활성화 상태라면 바로 다음 포트를 사용 또는 재사용 한다.

또한 재사용을 위해서는 net.ipv4.tcp_timestamps 타임스탬프 옵션이 서버/클라이언트 양쪽 모두 반드시 켜져 있어야 한다.<br>
(더 이해가 필요...)

## 개인생각
- TIME_WAIT 소켓이 많이 남아있다는 것은 그만큼 TCP연결이 빈번하게 발생하고 있다.<br>
  - 3 way handshake에 의한 오버헤드가 늘어난다.<br>
  - connection pool
- 로컬 포트의 고갈로 이어진다면, 더 이상 외부와의 통신이 안될 가능성이 있다.
  - tcp_tw_reuse 파라미터를 이용하는 것으로 TIME_WAIT 소켓을 재사용할 수 있다.

