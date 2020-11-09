## 생성되는 VM
<img width="1306" alt="provision" src="https://user-images.githubusercontent.com/19552819/98538817-b201c580-22ce-11eb-9eb1-d29bb7c5b8aa.png">


- Host 공용 네트워크
  - Host PC가 사용중인 공용 네트워크
  - Host와 동일한 segment의 ip를 부여받는다
  - 공유기 설정에 따라 IP할당이 안되는 경우가 있다
- NAT
  - 외부 인터넷으로의 단방향 통신 가능
  - VM끼리 통신 불가
  - VM의 pkg 설치 등에 사용
- Host only Network
  - 외부 인터넷과의 통신 불가
  - VM 및 호스트 PC와의 통신 가능

## cmd
```
vagrant up - vm 시작
vagrant halt - vm 정지
vagrant status - vm 상태확인
vagrant destroy - vm 제거
vagrant provision - 실행중인 VM에 대해 구성된 프로비저닝을 실행

* vm의 이름을 지정하여 특정 vm만 조작할 수 있다.
ex) vagrant up web1
```
