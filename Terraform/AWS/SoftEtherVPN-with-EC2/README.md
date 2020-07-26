## 개요
AWS EC2에 VPN SotfWare([SoftEther VPN](https://www.softether.org/))를 설치하여 VPN 서버를 구축하고 이를 통해 VPN 접속을 가능하게 한다.

https://www.softether.org/4-docs/1-manual/7._Installing_SoftEther_VPN_Server/7.3_Install_on_Linux_and_Initial_Configurations

### 생성되는 리소스
- vpc
  - subnet
  - internet gateway
  - route table
- SoftEther VPN Server with ec2 instance (t2.micro)

## 구축
### terraform으로 리소스 배포
```
$ terraform init
$ terraform plan
$ terraform apply
```

## Server 설정
### 생성된 EC2 instance에 접속하여 VPN Server 설정

1. 서버에 ssh 접속 후, VPN Server 설정을 위해 vpncmd 실행
- vpncmd 실행 후, `1. Management of VPN Server or VPN Bridge`를 선택하여 초기 VPN Server 및 VPN Bridge설정 진행
```
[root@foobar ~]# vpncmd
vpncmd command - SoftEther VPN Command Line Management Utility
SoftEther VPN Command Line Management Utility (vpncmd command)
Version 4.32 Build 9731 (English)
Compiled 2020/01/01 17:54:10 by buildsan at crosswin
Copyright (c) SoftEther VPN Project. All Rights Reserved.

By using vpncmd program, the following can be achieved.

1. Management of VPN Server or VPN Bridge
2. Management of VPN Client
3. Use of VPN Tools (certificate creation and Network Traffic Speed Test Tool)
Select 1, 2 or 3: 1
```

2. VPN Server 설정 : SoftEther VPN이 실행되고 있는 서버의 IP주소를 입력
- 포트 번호까지 지정 가능하지만, 이번 예시에서는 주소만 입력하여 443를 사용
```
Specify the host name or IP address of the computer that the destination VPN Server or VPN Bridge is operating on.
By specifying according to the format 'host name:port number', you can also specify the port number.
(When the port number is unspecified, 443 is used.)
If nothing is input and the Enter key is pressed, the connection will be made to the port number 8888 of localhost (this computer).
Hostname of IP Address of Destination: xx.xx.xx.xx
```

3. VPN Server 설정 : Virtual Hub Name은 아무것도 입력하지 않은 채 Enter
- 이 후 새로운 Virtual Hub를 생성
```
If connecting to the server by Virtual Hub Admin Mode, please input the Virtual Hub name.
If connecting by server admin mode, please press Enter without inputting anything.
Specify Virtual Hub Name:

Connection has been established with VPN Server "xx.xx.xx.xx" (port 443).

You have administrator privileges for the entire VPN Server.
```

4. Virtual Hub 설정 : 기존에 생성된 Default Virtual Hub 삭제
```
VPN Server>HubDelete
HubDelete command - Delete Virtual Hub
Name of Virtual Hub to delete: DEFAULT
The command completed successfully.
```

5. Virtual Hub 설정 : Virtual Hub 생성
- Virtual Hub 생성 시 설정하는 비밀번호는 추후 해당 허브에 접속할때 사용되므로 기억해둘 것
```
VPN Server>HubCreate foobarhub
HubCreate command - Create New Virtual Hub
Please enter the password. To cancel press the Ctrl+D key.

Password: *******
Confirm input: *******


The command completed successfully.
```

6. Virtual Hub 설정 : 생성한 Virtual Hub로 이동
```
VPN Server>HUB foobarhub
Hub command - Select Virtual Hub to Manage
The Virtual Hub "foobarhub" has been selected.
The command completed successfully.
```

7. Virtual Hub 설정 : IPsec 활성화
- ※1) 이 부분에서 생성한 Virtual Hub 이름 입력
- ※2) 여기서 생성하는 Pre Shared Key는 추후 VPN 접근 설정 시 사용되는 비밀번호이므로 기억해둘 것
```
VPN Server/foobarhub>IPsecEnable /L2TP:yes /L2TPRAW:no /ETHERIP:no /DEFAULTHUB:foobarhub ※1)
IPsecEnable command - Enable or Disable IPsec VPN Server Function
Pre Shared Key for IPsec (Recommended: 9 letters at maximum): ********* ※2)

The command completed successfully.
```

8. Virtual Hub 설정 : SecureNat 활성화 
```
VPN Server/foobarhub>SecureNatEnable
SecureNatEnable command - Enable the Virtual NAT and DHCP Server Function (SecureNat Function)
The command completed successfully.
```

9. Virtual Hub 설정 : Dhcp 활성화
```
VPN Server/foobar>hubDhcpset /Start:192.168.30.10 /End:192.168.30.200 /Mask:255.255.255.0 /Expire:7200 /GW:192.168.30.1 /DNS:192.168.30.1 /DNS2:none /Domain:none /Log:yes /PushRoute:"10.0.0.0/255.255.0.0/192.168.30.1"
DhcpSet command - Change Virtual DHCP Server Function Setting of SecureNAT Function
The command completed successfully.
```
### VPN에 접근하기 위한 유저 생성
1. user 생성 및 password 설정

```
VPN Server/foobarhub>UserCreate user1 /Group:none /REALNAME:none /NOTE:none
UserCreate command - Create User
The command completed successfully.

VPN Server/foobarhub>UserPasswordSet user1 /PASSWORD:foobar
UserPasswordSet command - Set Password Authentication for User Auth Type and Set Password
The command completed successfully.

VPN Server/foobarhub>exit
```

## Client 설정

### Mac
1. 네트워크 설정에서 새로운 인터페이스 설정 추가

<img width="600" alt="7" src="https://user-images.githubusercontent.com/19552819/88480995-29b41a80-cf94-11ea-8d0f-2b17754911d0.png">

2. 인터페이스 설정

- 인터페이스 : VPN
- 유형 : `IPSec을 통한 L2TP`
- 서비스 이름 : 원하는 이름

<img width="600" alt="7" src="https://user-images.githubusercontent.com/19552819/88480996-2ae54780-cf94-11ea-94f9-ad466677da1b.png">

3. VPN 접근을 위한 계정 이름 입력

- 서버주소 : SoftEther VPN이 가동 중인 서버의 ip주소
- 계정이름 : `VPN에 접근하기 위한 유저 생성` 에서 생성한 유저

<img width="600" alt="7" src="https://user-images.githubusercontent.com/19552819/88480997-2b7dde00-cf94-11ea-8e1d-2eabf30cc324.png">

4. 그 후 인증 설정으로 이동

<img width="600" alt="7" src="https://user-images.githubusercontent.com/19552819/88480998-2c167480-cf94-11ea-9421-2be3fa6a8fa8.png">

5. 인증 비밀번호 입력

- 사용자 인증 암호 : `VPN에 접근하기 위한 유저 생성` 에서 생성한 유저의 비밀번호
- 시스템인증 : `7. Virtual Hub 설정 : IPsec 활성화` 에서 입력한 Pre Shared Key

<img width="600" alt="7" src="https://user-images.githubusercontent.com/19552819/88480999-2c167480-cf94-11ea-8d0f-b4416f0f0ecb.png">

6. 그 후 고급 설정으로 이동

<img width="600" alt="7" src="https://user-images.githubusercontent.com/19552819/88481000-2caf0b00-cf94-11ea-9239-f5c4899e7e6e.png">

7. 세션 옵션 설정

- `VPN 연결을 통해 모든 트레픽 전송`을 체크

<img width="600" alt="7" src="https://user-images.githubusercontent.com/19552819/88481001-2caf0b00-cf94-11ea-8ddc-0b3fca71f592.png">

### Window
```
coming soon
```

## 참고
- 생성되는 EC2 instance는 ssm을 이용한 접근만을 허용한다.
  - 22번 포트는 열려있지 않다.
  - 접근 시, AWS 콘솔에서 ssm을 이용하여 접근한다.
- 생성되는 EC2 instance는 Amazon Linux 2를 이용한다.
  - ssm agent가 default로 설치된다.

