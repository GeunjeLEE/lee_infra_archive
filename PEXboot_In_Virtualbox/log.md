# 사전준비

# PXE환경준비

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