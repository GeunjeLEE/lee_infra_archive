# 사전 준비

## 버전 정보
실습에 사용한 VirtualBox 및 Guest OS 버전

- Host OS : Windows 10 Pro
- VirtualBox : 6.1.16 r140961 (Qt5.6.2)
- Guest OS : CentOS Linux release 7.9.2009
  - http://ftp.riken.jp/Linux/centos/7.9.2009/isos/x86_64/


## VirtualBox의 DHCP 서버 사용하지 않기

PXE boot환경을 구성하기 위해 DHCP 서버를 설치해야하는데, <br>
VirtualBox는 기본적으로 VirtualBox의 DHCP를 사용하기 때문에 네트워크 부팅 시, PXE의 DHCP를 찾아가는게 아니라<br>
VirtualBox의 DHCP를 찾아간다.

때문에 이를 사용하지 않도록 한다.

`[파일]` - `[호스트 네트워크 관리자]`로 들어가, Ether Adapter의 DHCP 서버 체크박스에서 사용함을 해제한다.<br>
또는 DHCP 서버를 사용하지 않는 Ether Adapter를 사용한다.

이번 실습에서는, DHCP 서버를 사용하지 않는 Ether Adapter가 있었기 때문에 그것을 그대로 사용했다.

사진-사전준비1

## VM의 네트워크 설정
PXE 환경을 구성할 VM을 생성한다.

네트워크 Adapter는 `NAT`과 `호스트전용 어댑터`를 사용한다.
- NAT는 외부로부터 패키지를 다운로드 받기 위한 용도로 사용한다.
- 호스트전용 어댑터는 서로 다른 VM과 통신하기 위한 용도로 사용한다.

`호스트전용 어댑터` 설정에서 위에서 설명한 것 처럼 DHCP 서버를 사용하지 않는 Ether Adapter를 선택한다.<br>
또한 어댑터 종류는 `Pcnet-FAST III`을 선택한다.( Intel PRO/1000 시리즈는 PXE Boot을 지원하지 않는다고 한다.)<br>
이렇게 되면, 운영체제 설치 시, 수동으로 IP설정을 잡아줘야 한다.

사진-네트워크1
사진-네트워크2

## 이후 과정
이후 과정은 보통의 VM 작성과 같다.<br>
memory/disk의 용량을 잡아주고, 사용할 OS iso image를 준비한 후 부팅한다.

참, DHCP 서버를 사용하지 않는 Ether Adapter를 사용하고 있기 때문에, <br>
`호스트전용 어댑터`의 IP는 수동으로 설정해줘야한다.(NAT 어댑터는 자동으로 잡힌다.)

기본적인 네트워크 IP 같은 정보는 `[파일]` - `[호스트 네트워크 관리자]`에서 참고한다.

## 참고
- https://www.joinc.co.kr/w/Site/cloud/virtualbox/PXE


