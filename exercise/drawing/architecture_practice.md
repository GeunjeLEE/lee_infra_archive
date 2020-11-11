## 연습1
![image](https://user-images.githubusercontent.com/19552819/98814534-25d7d580-2469-11eb-8b5d-50f2271ba3f6.png)

![image](https://user-images.githubusercontent.com/19552819/98814576-3425f180-2469-11eb-9ae4-44f52d30d8d5.png)

### note
- Firewall은 IP/Port기반으로 필터링한다.
  - 패킷 내부검사를 안하기 때문에
  - IDS/IPS 솔루션을 추가한다.
    - 근데 장비가 비싸다는데...
- APP이랑 DB,Storage랑 각각 다른 스위치에 물려놨는데
  - 굳이 나눌 필요가 있을까?
- Storage
  - 어떨때 검토?
    - 공용 스토리지가 필요할때
      - 한대의 서버에 연결해서 쓴다? -> DAS?
      - 다수의 서버에서 동시 접근이 필요하다? -> NAS?
        - NAS가 비싸서 한대 구성해서 다수의 서버에 공유?
    - 비용/안정선/구성/부하에 따라 어느걸 쓸지 고민한다.(당연하겠지만)
