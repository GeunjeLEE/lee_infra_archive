# PXE boot 환경 준비

## PXE 서버 부팅 후
처음 부팅 후, 이상하게 package download도 잘 안되고 ssh접속도 잘 되지 않았다.

routing table를 확인해보니, default gateway가 2개로 잡혀있었다.<br>
NAT쪽 NIC(10.0.2.0)가 package 등을 다운로드할 때 주로 사용될 것이므로, <br>
내부 통신을 위한 NIC의 default gateway는 삭제해주었다.

```
# route
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
default         gateway         0.0.0.0         UG    100    0        0 enp0s8　★ 제거
default         gateway         0.0.0.0         UG    101    0        0 enp0s3
10.0.2.0        0.0.0.0         255.255.255.0   U     101    0        0 enp0s3
192.168.99.0    0.0.0.0         255.255.255.0   U     100    0        0 enp0s8

# route del -net gateway dev enp0s8

# vim /etc/sysconfig/network-scripts/ifcfg-enp0s8
TYPE=Ethernet
DEVICE=enp0s8
ONBOOT=yes
IPADDR=192.168.99.10
.
.
gateway=192.168.99.1 <- 삭제
.
.
```

## PXE boot 환경 구성에 사용할 이미지 준비

PXE boot를 통해 네트워크 부팅이 되고, 이후 PXE client에게 제공할 iso파일을 준비한다.<br>
이번 실습의 경우, CentOS7을 준비했다.(iso 종류는 minimal으로 했다.)

```
# wget -P /tmp/ http://ftp.riken.jp/Linux/centos/7.9.2009/isos/x86_64/
```

## PXE boot 환경 구성을 위한 패키지 설치
이후, PXE boot 환경 구성을 위해 필요한 패키지를 설치.

```
# yum install -y httpd                    # iso 이미지 저장소를 위한 apache (FTP혹은 NFS로도 가능하다고 한다.)
# yum install -y dhcpd                    # PXE client가 초기 ip 할당을 요청하기 위한 dhcp
# yum install -y tftp tftp-server xinetd  # PXE client가 부팅하기 위한 부팅 이미지(pxelinux.0 등)는 TFTP를 통해 전달한다.
# yum install -y syslinux                 # SYSLINUX는 MS-DOS / Windows FAT 파일 시스템에서 실행되는 Linux 운영체제용 부트로더.
```

## 설정 - 파일 저장소(httpd)
PXE client가 PXE 부팅이 되고, 이후 실제 이미지 파일을 가져오기 위한 저장소로 사용된다.

설치, 서비스 시작 단계는 생략한다.<br>
httpd 서비스 시작 후, 접근이 되지 않는다면 selinux나 firewall 설정을 조정한다.<br>
이번 예제에서는 모두 disable로 설정했다.

apache 설정에서 DocumentRoot를 /var/www로 변경했다.<br>
이후 준비해둔 iso 파일을 일시적으로 mount하고, iso 안의 파일을 모두 /var/www 이하로 배치하여 저장소를 구성하였다.

```
# mkdir -p /var/www/iso/centos/x86_64/7

# mkdir /tmp/iso
# mount -o loop CentOS-7-x86_64-Minimal-2009.iso /tmp/iso
# cp -r /tmp/iso/* /var/www/iso/centos/x86_64/7/

# umount /tmp/iso
```


## 설정 - DHCP
처음 PXE client가 시작되고, IP정보와 TFTP정보를 얻기위한 DHCP이다.

DHCP는 일반적인 구성과 동일하지만, TFTP 구성을 위해 몇 가지 추가해야 할 내용들이 있다.

자세한 설정 내용을 파악하고 필요에 의한 설정을 적당히 선택해야하지만,<br>
이번 실습에서는 오로지 PXE boot를 성공시키기 위한 최소한의 구성만 한다.

- DHCP가 사용하는 네트워크 인터페이스를 지정
```
# vim /etc/sysconfig/dhcpd
.
.
.
DHCPDARGS = enp0s8 <-추가, VM 네트워크 설정 당시 설정한 호스트전용 어댑터의 인터페이스 이름을 추가한다.
```

- DHCP 설정
```
# vim /etc/dhcp/dhcpd.conf

ddns-update-style none;
option domain-name "example.org";

default-lease-time 60;
max-lease-time 72;
authoritative;

subnet 192.168.99.0 netmask 255.255.255.0 {
        option routers 192.168.99.1;
        option subnet-mask 255.255.255.0;
        range dynamic-bootp 192.168.99.2 192.168.99.254;
        option domain-name-servers 8.8.8.8, 8.8.6.6;
        allow booting;
        allow bootp;
        allow unknown-clients;
        next-server 192.168.99.10; #pxe server의 ip주소
        filename "pxelinux.0";
}

```

- DHCP 서비스 시작
```
# systemctl enable dhcp
# systemctl start dhcp
```

## 설정 - TFTP
네트워크 부팅 이후, 리눅스 커널 설치 등에 필요한 파일(vmlinuz/pxelinux.0 등)은 TFTP로 전송된다.

TFTP는 xinetd 기반으로 실행된다.

- tftp 서비스의 기본 설정이 disable=yes로 되어있기 때문에 이곳을 no로 변경한다.
```
# vim /etc/xinetd.d/tftp
service tftp 
{
        socket_type             = dgram
        protocol                = udp
        wait                    = yes
        user                    = root
        server                  = /usr/sbin/in.tftpd
        server_args             = -s /var/lib/tftpboot  # tftpboot 디렉토리 / pxelinux.0등의 파일을 배치해두는 곳
        disable                 = no                    # yes->no 로 변경
        per_source              = 11
        cps                     = 100 2
        flags                   = IPv4
}
```

- xinetd(TFTP) 서비스 재시작
```
# systemctl restart xinetd
```

## 설정 - syslinux bootloader 파일 준비 및 PXE Menufile, 준비
PXE client가 네트워크로 부팅되면서 가져가야할 부트로더, PXE Menufile 및 kernel 파일 등을 준비한다.


- PXE Client가 로드할 부트로더 파일을 tftpboot 디렉토리(/var/lib/tftpboot)로 가져온다.
```
# cp -ip /usr/share/syslinux/{menu.c32,pxelinux.0} /var/lib/tftpboot
```

- PXE Menufile및 kernel 파일을 준비한다.
```
# mkdir /var/lib/tftpboot/pxelinux.cfg
# mkdir -p /var/lib/tftpboot/images/centos/x86_64/7/

커널 파일 및 커널 모듈 파일 준비
# cp -ip /var/www/iso/centos/x86_64/7/images/pxeboot/{vmlinuz,initrd.img} /var/lib/tftpboot/images/centos/x86_64/7/

PXE Menufile 설정
# vim /var/lib/tftpboot/pxelinux.cfg/default
default menu.c32
prompt 0
timeout 30
MENU TITLE LEE PXE Menu # PXE client 부팅 이후, 화면에 표시 될 메뉴 타이틀
LABEL centos7
  menu label centos7-x86_64
  kernel images/centos/x86_64/7/vmlinuz
  append initrd=images/centos/x86_64/7/initrd.img inst.repo=http://192.168.99.10/iso/centos/x86_64/7 ks=http://192.168.99.10/ks/centos7.cfg

kernel은 PXE kernel 파일이 위치하는 디렉토리.
append는 커널 모듈 파일과, 설치 소스, 즉 설치 프로그램이 필요한 이미지와 패키지를 찾을 수 있는 위치, kickstart 파일이 위치한 곳을 지정한다.
```

## 설정 kickstart 파일
PXE boot는 네트워크 부팅을 지원하지만, 운영체제 설치의 자동화까지는 지원해주지 않는다.

이를 자동화하기 위해 kickstart 파일을 준비하고, PXE boot시 kickstart을 제공하여<br>
network, disk, package install 등의 설정을 자동화 한다.

kickstart 파일은 위에 구성해두었던 파일 저장소에 배치하고, HTTP를 이용해 다운받게 된다.

[KICKSTART SYNTAX REFERENCE](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/installation_guide/sect-kickstart-syntax)


- kickstart 설정
  - 이번 실습에서는 NAT 인터페이스가 따로 있으므로, --nodefroute 옵션을 주어, enp0s3의 default gateway가 설정되지 않도록 했다.
```
# vim /var/www/ks/centos.ks
# System authorization information
auth --enableshadow --passalgo=sha512
# Use CDROM installation media
cdrom
# Use graphical install
graphical
# Run the Setup Agent on first boot
firstboot --enable
# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'
# System language
lang en_US.UTF-8
# Selinux
selinux --disabled

url --url=http://192.168.99.10/iso/centos/x86_64/7
repo --name=base --baseurl=http://mirror.centos.org/centos/7/os/x86_64/

# Network information
network --onboot yes --bootproto=dhcp --device=enp0s3 --ipv6=auto --nodefroute --activate
network --hostname=localhost.localdomain

# Root password
rootpw --iscrypted [root 비밀번호 지정]

# System services
services --enabled="chronyd"

# System timezone
timezone --utc Asia/Seoul

# System bootloader configuration
bootloader --append=" crashkernel=auto" --location=mbr --boot-drive=sda

# Partition clearing information
clearpart --none --initlabel
autopart

%packages
@core
chrony
kexec-tools

%end

%addon com_redhat_kdump --enable --reserve-mb='auto'

%end

%anaconda
pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
%end

```

## 참고
- https://www.joinc.co.kr/w/Site/System_management/PXEBoot
- https://youngmind.tistory.com/entry/CentOS-%EA%B0%95%EC%A2%8C-PART-2-10-PXE%EA%B8%B0%EB%B0%98%EC%9D%98-CentOS-%EC%84%9C%EB%B2%84-%EC%9E%90%EB%8F%99-%EA%B5%AC%EC%B6%95-2%ED%8E%B8?category=783197
