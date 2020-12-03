# 주요 요소

## PXE
컴퓨터가 네트워크를 통해 부팅 할 수 있는 방법에는 여러 가지가 있으며 PXE(Preboot Execution Environment)가 그 중 하나이다.

PXE는 시스템의 네트워크 인터페이스 카드(NIC)와 함께 작동하여 부팅 장치처럼 작동한다.
즉, 네트워크 인터페이스를 통해 머신을 부팅(운영체제를 설치)할 수 있게 해주는 환경이다.

클라이언트의 PXE사용 NIC는 DHCP 서버로 브로드 캐스트 요청을 전송하고,
이 요청은 클라이언트의 IP 주소와 TFTP 서버의 주소 및 TFTP 서버의 부팅 파일과 함께 반환된다.

구체적인 작동 방식으로는
1. 대상 머신이 부팅된다.
2. 머신은 NIC를 통해 DHCP로 요청을 보낸다.
3. DHCP 서버는 해당 요청에 대해 표준 정보(IP, 서브넷 마스크, 게이트웨이, DNS 등)를 반환한다. 또한 TFTP 서버 및 부팅 이미지(pxelinux.0)의 위치에 대한 정보를 제공한다.
4. 클라이언트가 이 정보를 받으면 부팅 이미지를 얻기 위해 TFTP 서버로 연결한다.
5. TFTP 서버는 부팅 이미지 (pxelinux.0)를 전송하고 클라이언트는 이를 실행한다.
6. 기본적으로 부팅 이미지는 TFTP 서버의 pxelinux.cfg 디렉토리에서 다음 접근 방식을 사용하여 TFTP 서버의 부팅 구성 파일을 검색한다.<br>
   먼저 소문자 16 진수로 표시된 MAC 주소에 따라 이름이 지정된 부팅 구성 파일을 검색한다.<br>
   예를 들어 MAC 주소 "88:99:AA:BB:CC:DD"의 경우 01-88-99-aa-bb-cc-dd 파일을 검색한다.<br>

   그런 다음 (부팅중인 머신의)대문자 16 진수의 IP 주소를 사용하여 구성 파일을 검색한다. <br>
   예를 들어 IP 주소 "192.0.2.91"의 경우 "C000025B"파일을 검색한다.<br>

   해당 파일이 없으면 끝에서 16 진수 하나를 제거하고 다시 시도한다. <br>
   그러나 검색이 여전히 성공하지 못하면 마지막으로 "default" 파일을 찾는다.

   예를 들어 부팅 파일 이름이 /tftpboot/pxelinux.0 이고 이더넷 MAC 주소가 88:99:AA:BB:CC:DD이고 IP 주소가 192.0.2.91 인 경우<br>
   부팅 이미지는 다음 위치에서 파일 이름을 찾는다.
   ```
   /tftpboot/pxelinux.cfg/01-88-99-aa-bb-cc-dd
   /tftpboot/pxelinux.cfg/C000025B
   /tftpboot/pxelinux.cfg/C000025
   /tftpboot/pxelinux.cfg/C00002
   /tftpboot/pxelinux.cfg/C0000
   /tftpboot/pxelinux.cfg/C000
   /tftpboot/pxelinux.cfg/C00
   /tftpboot/pxelinux.cfg/C0
   /tftpboot/pxelinux.cfg/C
   ```
7. 클라이언트는 필요한 모든 파일(커널 및 루트 파일 시스템)을 다운로드 한 다음 로드한다.
8. 대상 머신이 재부팅된다.

## kickstart
킥 스타트 설치는 부분적으로 또는 전체적으로 설치 프로세스를 자동화하는 수단을 제공한다.<br>
킥 스타트 파일에는 시스템에서 사용할 시간대, 드라이브를 분할하는 방법, 설치할 패키지 등이 포함되어 있다.

따라서 설치가 시작될 때 준비된 킥 스타트 파일을 제공하면 사용자의 개입없이 자동으로 설치를 수행 할 수 있다.<br>
이것은 한 번에 많은 시스템에 CentOS를 배포 할 때 특히 유용하다.

## TFTP
TFTP(Trivial File Transfer Protocol)란 이더넷을 이용하여 파일을 다운 받는 프로토콜 로직이다.<br>
TFTP은 ftp와 마찬가지로 파일을 전송하기 위한 프로토콜이지만, FTP보다 더 단순한 방식으로 파일을 전송한다.<br>

차이점 중 하나는 TFTP의 전송 프로토콜은 UDP를 사용하는 반면<br> 
FTP는 정보 보안을 위해 TCP(Transmission Control Protoco)를 사용한다.

시스템 관리자는 일반적으로 다음을 위해 TFTP 구성을 사용한다.

- 파일 전송
- 하드 드라이브없이 원격 부팅
- 코드 업그레이드
- 네트워크 구성 백업
- 라우터 구성 파일 백업
- IOS 이미지 저장
- 디스크없이 PC 부팅

## DHCP
DHCP(Dynamic Host Configuration Protocol),말 그대로 동적 호스트 구성 프로토콜은 호스트 IP 구성 관리를 단순화하는 IP 표준이다.
동적 호스트 구성 프로토콜 표준에서는 DHCP 서버를 사용하여 IP 주소 및 관련된 기타 구성 세부 정보를 네트워크의 DHCP 사용 클라이언트에게 동적으로 할당하는 방법을 제공한다.

DHCP 동작 원리는 크게 네 단계로 단말과 서버 간에 통신이 이루어진다.

- 1) DHCP Discover :<br>
메시지 방향: `단말 → DHCP 서버`로 이루어지며<br>
브로드캐스트 메시지(Destination MAC = FF:FF:FF:FF:FF:FF)를 통해서 단말장비가 DHCP 서버에게 아이피 주소를 할당을 요청한다.

- 2) DHCP Offer :<br>
메시지 방향: `DHCP 서버 → 단말`로 이루어진다.<br>
브로드캐스트 메시지 (Destination MAC = FF:FF:FF:FF:FF:FF)이거나 유니캐스트를 통해서 이루어지며,<br>
단말에서 요청을 한 아이피 주소 정보를 포함한 네트워크 정보의 할당 요청을 DHCP 서버가 받아서 이것에 대해서 응답을 한다.<br>
이때 아이피 주소 정보 와 단말의 MAC주소 정보 등을 네트워크 정보와 함께 같이 전송한다.

- 3) DHCP Request:<br>
메시지 방향: `단말 → DHCP 서버`로 이루어진다.<br>
브로드캐스트 메시지(Destination MAC = FF:FF:FF:FF:FF:FF)로 단말이 받은 아이피 주소 정보를 사용하겠다는 것을 서버로 보내서 확정을 받기 위한 메시지이다.

- 4) DHCP Ack:<br>
메시지 방향: `DHCP 서버 → 단말`로 이루어진다.<br>
브로드캐스트 메시지 (Destination MAC = FF:FF:FF:FF:FF:FF) 혹은 유니캐스트일수 있다.<br>
단말에서 보낸 DHCP Request 메시지 내의 Broadcast Flag가 1이면 DHCP 서버는 DHCP Ack 메시지를<br>
Broadcast Flag가 0 이면 Unicast로 보내주며 단말의 MAC 어드레스에 매칭이 되는 IP 주소와 게이트웨이 주소를 확정하여 주는 것이다.

## 그 외

### FTP/HTTP/NFS
클라이언트를 위한 kickstart file과 system image file을 제공하기위해 필요.

### vmlinuz
리눅스 커널을 컴파일한 결과인 바이너리 파일을 bzImage를 사용하여 gzip으로 압축한 것.<br>
리눅스 부팅시 이 파일은 압축을 해제되며 메모리에 로딩되어 리눅스의 운영이 시작된다.

### initrd.img
커널 모듈을 모아놓은 이미지로 커널이 로딩되기전에 메모리에 미리 로딩된다.<br>
마우스 드라이버나 그랙픽카드 모듈 등이 있다.<br>
인텔 그래픽 카드를 사용하는 본체에 리눅스를 부팅하게되면 initrd.img의 인텔 그래픽 카드 모듈이 메모리에 로딩된다.

### syslinux
SYSLINUX는 MS-DOS / Windows FAT 파일 시스템에서 실행되는 Linux 운영체제용 부트로더.

### pxelinux.0
syslinux 패키지에 포함되어있는 파일로 대부분의 시스템에는 기본적으로 설치가 되어있다.<br>
pxelinux.0 는 네트워크 부트로더로 리눅스의 grub 이나 lilo 와 같은 역할을 한다.


# 참고
- https://wiki.syslinux.org/wiki/index.php?title=PXELINUX
