## 저장소 로그
- initrd.img,vmlinuz와 같은 파일은 TFTP로 가져가고
  - 나머지 ks나 package, OS image는 저장소로부터 가져가는 것 같다.
  - 저장소는 따로 분리해도 좋을 것 같다. / 또는 mirror site등으로 해도 괜찮을까?
    - ks 역시, 다른 곳을 참조해오는 방식으로도 좋을 것 같기도 하다. 아니 가능할 것 같다.
```
00.00.00.00 - - [03/Dec/2020:06:55:49 -0500] "GET /iso/centos/x86_64/7/.treeinfo HTTP/1.1" 200 354 "-" "curl/7.29.0"
00.00.00.00 - - [03/Dec/2020:06:55:49 -0500] "GET /iso/centos/x86_64/7/LiveOS/squashfs.img HTTP/1.1" 200 521617408 "-" "curl/7.29.0"
00.00.00.00 - - [03/Dec/2020:06:55:58 -0500] "GET /iso/centos/x86_64/7/images/updates.img HTTP/1.1" 404 236 "-" "curl/7.29.0"
00.00.00.00 - - [03/Dec/2020:06:55:58 -0500] "GET /iso/centos/x86_64/7/images/product.img HTTP/1.1" 404 236 "-" "curl/7.29.0"
00.00.00.00 - - [03/Dec/2020:06:55:59 -0500] "GET /ks/centos7_apache.cfg HTTP/1.1" 200 1417 "-" "curl/7.29.0"
00.00.00.00 - - [03/Dec/2020:06:56:21 -0500] "GET /iso/centos/x86_64/7/.treeinfo HTTP/1.1" 200 354 "-" "urlgrabber/3.10"
00.00.00.00 - - [03/Dec/2020:06:56:21 -0500] "GET /iso/centos/x86_64/7/repodata/repomd.xml HTTP/1.1" 200 3734 "-" "CentOS (anaconda)/7 yum/3.4.3"
00.00.00.00 - - [03/Dec/2020:06:56:21 -0500] "GET /iso/centos/x86_64/7/.treeinfo HTTP/1.1" 200 354 "-" "urlgrabber/3.10"
00.00.00.00 - - [03/Dec/2020:06:56:23 -0500] "GET /iso/centos/x86_64/7/repodata/136912ae46ca9ed27661ea6528fd544962d83095e3cdbc6149a37ddedf3a153c-primary.xml.gz HTTP/1.1" 200 409248 "-" "CentOS (anaconda)/7 yum/3.4.3"
00.00.00.00 - - [03/Dec/2020:06:56:23 -0500] "GET /iso/centos/x86_64/7/repodata/d4de4d1e2d2597c177bb095da8f1ad794d69f76e8ac7ab1ba6340fdd0969e936-c7-minimal-x86_64-comps.xml.gz HTTP/1.1" 200 3539 "-" "CentOS (anaconda)/7 yum/3.4.3"
00.00.00.00 - - [03/Dec/2020:06:56:27 -0500] "GET /iso/centos/x86_64/7/repodata/b6404d2de68763bab0d9fa3f8e1d6f5bc057b2c4a1919a89cc083d5dbc6efb19-primary.sqlite.bz2 HTTP/1.1" 200 851584 "-" "CentOS (anaconda)/7 yum/3.4.3"
00.00.00.00 - - [03/Dec/2020:06:56:27 -0500] "GET /iso/centos/x86_64/7//repodata/repomd.xml HTTP/1.1" 200 3734 "-" "urlgrabber/3.10"
00.00.00.00 - - [03/Dec/2020:06:56:51 -0500] "GET /iso/centos/x86_64/7/Packages/firewalld-filesystem-0.6.3-11.el7.noarch.rpm HTTP/1.1" 206 50160 "-" "urlgrabber/3.10 yum/3.4.3"
00.00.00.00 - - [03/Dec/2020:06:56:51 -0500] "GET /iso/centos/x86_64/7/Packages/glibc-common-2.17-317.el7.x86_64.rpm HTTP/1.1" 206 310532 "-" "urlgrabber/3.10 yum/3.4.3"
00.00.00.00 - - [03/Dec/2020:06:56:51 -0500] "GET /iso/centos/x86_64/7/Packages/nss-3.44.0-7.el7_7.x86_64.rpm HTTP/1.1" 206 67152 "-" "urlgrabber/3.10 yum/3.4.3"
00.00.00.00 - - [03/Dec/2020:06:56:51 -0500] "GET /iso/centos/x86_64/7/Packages/iwl6000g2a-firmware-18.168.6.1-79.el7.noarch.rpm HTTP/1.1" 206 19000 "-" "urlgrabber/3.10 yum/3.4.3"
00.00.00.00 - - [03/Dec/2020:06:56:51 -0500] "GET /iso/centos/x86_64/7/Packages/grubby-8.28-26.el7.x86_64.rpm HTTP/1.1" 206 18280 "-" "urlgrabber/3.10 yum/3.4.3"
00.00.00.00 - - [03/Dec/2020:06:56:51 -0500] "GET /iso/centos/x86_64/7/Packages/iwl100-firmware-39.31.5.1-79.el7.noarch.rpm HTTP/1.1" 206 18844 "-" "urlgrabber/3.10 yum/3.4.3"
00.00.00.00 - - [03/Dec/2020:06:56:51 -0500] "GET /iso/centos/x86_64/7/Packages/openssh-server-7.4p1-21.el7.x86_64.rpm HTTP/1.1" 206 75916 "-" "urlgrabber/3.10 yum/3.4.3"
00.00.00.00 - - [03/Dec/2020:06:56:51 -0500] "GET /iso/centos/x86_64/7/Packages/fipscheck-1.4.1-6.el7.x86_64.rpm HTTP/1.1" 206 5944 "-" "urlgrabber/3.10 yum/3.4.3"
00.00.00.00 - - [03/Dec/2020:06:56:51 -0500] "GET /iso/centos/x86_64/7/Packages/libsemanage-2.5-14.el7.x86_64.rpm HTTP/1.1" 206 49980 "-" "urlgrabber/3.10 yum/3.4.3"
00.00.00.00 - - [03/Dec/2020:06:56:51 -0500] "GET /iso/centos/x86_64/7/Packages/dhcp-libs-4.2.5-82.el7.centos.x86_64.rpm HTTP/1.1" 206 81076 "-" "urlgrabber/3.10 yum/3.4.3"
00.00.00.00 - - [03/Dec/2020:06:56:51 -0500] "GET /iso/centos/x86_64/7/Packages/iptables-1.4.21-35.el7.x86_64.rpm HTTP/1.1" 206 88672 "-" "urlgrabber/3.10 yum/3.4.3"
```
## TFTP
yum install tftp tftp-server xinetd

## syslinux
syslinux

mkdir /srv/tftpboot
find ./ -name syslinux
cp -ip /usr/share/syslinux/pxelinux.0 /srv/tftpboot
cp -ip /usr/share/syslinux/menu.c32 /srv/tftpboot

## pxelinux
cp /var/www/iso/centos/x86_64/7.9/images/pxeboot/{initrd.img,vmlinuz} ./

## 참고
https://www.joinc.co.kr/w/Site/cloud/virtualbox/PXE
https://www.joinc.co.kr/w/Site/System_management/PXEBoot
https://www.joinc.co.kr/w/Site/System_management/dhcp
https://youngmind.tistory.com/entry/CentOS-%EA%B0%95%EC%A2%8C-PART-2-10-PXE%EA%B8%B0%EB%B0%98%EC%9D%98-CentOS-%EC%84%9C%EB%B2%84-%EC%9E%90%EB%8F%99-%EA%B5%AC%EC%B6%95-2%ED%8E%B8?category=783197

## dhcpd.conf
```
ddns-update-style none;

# option definitions common to all supported networks...
option domain-name "example.org";

# google dns 
option domain-name-servers 8.8.8.8, 8.8.6.6;

# gateway 
option routers 192.168.99.1;

# subnet mask
option subnet-mask 255.255.255.0;

default-lease-time 60;
max-lease-time 72;

subnet 192.168.99.0 netmask 255.255.255.0 {
        option routers 192.168.99.1;
        option subnet-mask 255.255.255.0;
        range dynamic-bootp 192.168.99.2 192.168.99.254;
        option domain-name-servers 8.8.8.8, 8.8.6.6;
        allow booting;
        allow bootp;
        next-server 192.168.99.10; #pxe server
        filename "pxelinux.0";
}
```

## pxelinux.cfg
```
default menu.c32
prompt 0
timeout 5
MENU TITLE LEE PXE Menu
LABEL centos7.9
  menu label centos7.9-x86_64
  kernel images/centos/x86_64/7.9/vmlinuz
  append initrd=images/centos/x86_64/7.9/initrd.img
```


## minimal하고.
1. firewall삭제
2. httpd documentroot변경 / welcomd삭제

메모리 최소 2GB이상으로.