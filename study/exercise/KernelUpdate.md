참고 : https://www.howtoforge.com/tutorial/how-to-upgrade-kernel-in-centos-7-server/

## How to Upgrade the Linux Kernel on CentOS 7
커널은 operating system의 핵심이다.<br>
Linux 커널은 Linux 컴퓨터 운영 체제의 모놀리식 Unix 유사 커널이다.

커널은 리눅스 토발즈에 의해 만들어졌으며<br>
Ubuntu, CentOS 및 Debian을 포함한 모든 Linux distribution은 이 커널을 기반으로 한다.

이 튜토리얼에서는 CentOS7의 커널을 최신 버전으로 upgrade하는 내용을 다룬다.<br>
ELRepo repository에서 precompile된 kernel을 사용할 것이다.

기본적으로 CentOS7은 3.10 버전의 커널을 사용한다.<br>
이 튜토리얼 과정을 통해 최신 버전의 커널을 설치 할 것이다.
(2020.12.08 기준, 5.9.12버전)

## What is the ELRepo
ELRepo은 Enterprise Linux를 위한 커뮤니티 기반 저장소이고<br>
RedHat Enterprise 및 이것을 기반으로 하는 다른 Linux distribution(CentOS, Scientific, Fedora)를 지원한다.

ELRepo는 하드웨어와 관련된 패키지에 중점을 둔다. 
(파일 시스템 드라이버, 그래픽 드라이버, 네트워크 드라이버, 사운드 카드 드라이버, 웹캠 등을 포함하여)

## What we will do
- Update and Upgrade CentOS 7
- Checking the Kernel Version
- Add ELRepo Repository
- Install New Kernel Version
- Configure Grub2
- Remove Old Kernel

## 1. Update and Upgrade CentOS 7
가장 먼저, 커널을 업그레이드 하기 전에 모든 패키지를 최신 버전으로 업그레이드 한다.
```
[root@localhost ~]# yum update -y
```

그 후, 좀 더 빠르게 패키지를 업데이트하고 설치하기 위해 yum plugin을 설치한다.
```
[root@localhost ~]# yum install yum-plugin-fastestmirror -y
```

## 2. Checking the Kernel Version
현재 커널의 버전 등을 확인한다.

```
[root@localhost ~]# cat /etc/redhat-release
CentOS Linux release 7.9.2009 (Core)
[root@localhost ~]# cat /etc/os-release
NAME="CentOS Linux"
VERSION="7 (Core)"
ID="centos"
ID_LIKE="rhel fedora"
VERSION_ID="7"
PRETTY_NAME="CentOS Linux 7 (Core)"
ANSI_COLOR="0;31"
CPE_NAME="cpe:/o:centos:centos:7"
HOME_URL="https://www.centos.org/"
BUG_REPORT_URL="https://bugs.centos.org/"

CENTOS_MANTISBT_PROJECT="CentOS-7"
CENTOS_MANTISBT_PROJECT_VERSION="7"
REDHAT_SUPPORT_PRODUCT="centos"
REDHAT_SUPPORT_PRODUCT_VERSION="7"
```

커널 버전을 확인하기 위해서는, `uname` 커맨드를 이용해서 확인할 수도 있다.
```
[root@localhost ~]# uname -snr
Linux localhost.localdomain 3.10.0-1160.el7.x86_64
```

## 3. Add ELRepo Repository
새로운 버전의 커널을 설치하기 전, 새로운 저장소(ELRepo repository.)를 추가해야한다.

ELRepo gpg 키를 추가한다.
```
[root@localhost ~]# rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
[root@localhost ~]#
[root@localhost ~]# rpm -Uvh https://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
```

그리고 이것이 모두 완료되면, 시스템의 활성화된 저장소를 확인하여 ELRepo가 목록에 들어있는지 확인한다.
```
[root@localhost ~]# yum repolist
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: ftp-srv2.kddilabs.jp
 * elrepo: ftp.ne.jp
 * extras: ftp-srv2.kddilabs.jp
 * updates: ftp-srv2.kddilabs.jp
repo id                repo name                                                        status
base/7/x86_64          CentOS-7 - Base                                                  10,072
elrepo                 ELRepo.org Community Enterprise Linux Repository - el7              130 ★
extras/7/x86_64        CentOS-7 - Extras                                                   448
updates/7/x86_64       CentOS-7 - Updates                                                  778
```

## 4. Install New CentOS Kernel Version
ELRepo 저장소에서 최신 버전의 커널을 설치한다.

```
[root@localhost ~]# yum --enablerepo=elrepo-kernel install kernel-ml
```
`--enablerepo=`은 특정 저장소를 활성화하는 옵션이다.<br>
기본적으로 elrepo 저장소는 활성화 되어있지만, elrepo-kernel 저장소는 활성화 되어있지 않다.

```
[root@localhost ~]# yum repolist all
(생략)
C7.8.2003-updates/x86_64                   CentOS-7.8.2003 - Updates                                                        disabled
base/7/x86_64                              CentOS-7 - Base                                                                  enabled: 10,072
base-debuginfo/x86_64                      CentOS-7 - Debuginfo                                                             disabled
base-source/7                              CentOS-7 - Base Sources                                                          disabled
c7-media                                   CentOS-7 - Media                                                                 disabled
centos-kernel/7/x86_64                     CentOS LTS Kernels for x86_64                                                    disabled
centos-kernel-experimental/7/x86_64        CentOS Experimental Kernels for x86_64                                           disabled
centosplus/7/x86_64                        CentOS-7 - Plus                                                                  disabled
centosplus-source/7                        CentOS-7 - Plus Sources                                                          disabled
cr/7/x86_64                                CentOS-7 - cr                                                                    disabled
elrepo                                     ELRepo.org Community Enterprise Linux Repository - el7                           enabled:    130
elrepo-extras                              ELRepo.org Community Enterprise Linux Extras Repository - el7                    disabled
elrepo-kernel                              ELRepo.org Community Enterprise Linux Kernel Repository - el7                    disabled ★
elrepo-testing                             ELRepo.org Community Enterprise Linux Testing Repository - el7                   disabled
(생략)
```

## 5. Configure Grub2 on CentOS 7
4번의 과정으로 통해, 이미 새로운 버전의 커널을 시스템에 설치했으므로<br>
이제는 시스템이 시작될 때 로드할 defualt 커널 버전을 설정한다.

아래의 명령어로 Grub2에서 유효한(사용 가능한) 커널 버전을 확인한다.<br>
(Grub2 = 부트로더)

```
[root@localhost ~]# awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg
0 : CentOS Linux (5.9.12-1.el7.elrepo.x86_64) 7 (Core)
1 : CentOS Linux (3.10.0-1160.6.1.el7.x86_64) 7 (Core)
2 : CentOS Linux (3.10.0-1160.el7.x86_64) 7 (Core)
3 : CentOS Linux (0-rescue-03188c4e40e13d45a48200aaa5dc8a97) 7 (Core)
```

새로운 버전(5.9.12)의 커널이 있는 것을 확인하고, 시스템이 시작될 때 사용될 default 커널 버전을 <br>
새로운 버전의 커널로 설정해준다.
```
[root@localhost ~]# grub2-set-default 0
```

만약, 이전의 커널 버전으로 되돌리고 싶다면 0을 해당 커널 버전의 번호로 변경하여 명령어를 실시한다.
```
[root@localhost ~]# grub2-set-default 1
```

설정이 완료되면, `gurb2-mkconfig` 명령어를 이용해 grub2 설정을 generate 하고 시스템을 reboot한다.
```
[root@localhost ~]# grub2-mkconfig -o /boot/grub2/grub.cfg
[root@localhost ~]# reboot
```

reboot이 완료되면, 커널 버전을 확인하여 현재 커널이 최신 버전으로 되었는지 확인한다.
```
[root@localhost ~]# uname -snr
Linux localhost.localdomain 5.9.12-1.el7.elrepo.x86_64
```


## 6. Remove an Old Kernel (Optional)

이 단계는 선택적으로 진행한다.<br>
시스템에 3~5개 이상의 커널 버전이 설치되어있는 경우, 이 작업을 통해 옛날 버전의 커널을 삭제한다.

우선 yum-utils 유틸리티를 설치한다.
```
[root@localhost ~]# yum install yum-utils
```

이후, 아래의 명령어로 옛날 버전의 커널을 정리한다.

```
[root@localhost ~]# package-cleanup --oldkernels
```

만약, 아래와 같은 출력만이 표시된다면, 현재 시스템에 설치되어있는 커널 버전이 2~3개 일 경우이다.<br>
그 이상인 경우, 시스템에서 옛날 버전의 커널을 자동으로 제거한다.
```
[root@localhost ~]# package-cleanup --oldkernels
Loaded plugins: fastestmirror
No old kernels to remove
```