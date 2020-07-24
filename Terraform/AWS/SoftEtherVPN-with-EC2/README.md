## 개요
AWS EC2에 VPN SotfWare([SoftEther VPN](https://www.softether.org/))를 설치하여 VPN 서버를 구축하고 이를 통해 VPN 접속을 가능하게 한다.

https://www.softether.org/4-docs/1-manual/7._Installing_SoftEther_VPN_Server/7.3_Install_on_Linux_and_Initial_Configurations

### 생성되는 리소스
- vpc
  - subnet
  - internet gateway
  - route table
- SoftEther VPN Server with ec2 instance (t2.micro)

## 구축 & 사용 방법
1. terraform으로 필요한 리소스 배포
```
$ terraform init
$ terraform plan
$ terraform apply
```

2. 생성된 EC2 instance에 접속하여 가상 허브 생성 및 유저 생성
```
comming soon
```

3. 로컬 환경에서 vpn server에 접근하도록 설정
```
comming soon
```

### 참고
- 생성되는 EC2 instance는 ssm을 이용한 접근만을 허용한다.
  - 22번 포트는 열려있지 않다.
  - 접근 시, AWS 콘솔에서 ssm을 이용하여 접근한다.
- 생성되는 EC2 instance는 Amazon Linux 2를 이용한다.
  - ssm agent가 default로 설치된다.

