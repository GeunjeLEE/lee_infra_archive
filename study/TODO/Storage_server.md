# 스토리지 서버
## 서버와 스토리지를 연결하는 방법으로는
- DAS, NAS, SAN이 있다.

![sannasdas1](https://user-images.githubusercontent.com/19552819/98459077-666def80-21da-11eb-882e-a9783b7ce7b5.png)

- DAS/Direct Attached Storege
  - 서버에 직접 저장장치를 연결한다.
  - 프로토콜
    - ATA・SATA
    - SCSI・SAS
    - Fiber channel


- NAS/Network Attached Storage
  - 스토리지를 기존 네트워크에 연결하고, 네트워크를 통해 서버와 연결된다.
  - 프로토콜
    - CIFS
    - NFS
    - SMB
    - FTP
    - HTTP


- SAN/Storage Area Network
  - 별도의 스토리지 전용의 네트워크(SAN)를 구축하여 스토리지를 통합하고, 스토리지 네트워크와 연결해 서버와 연결한다.
    - "스토리지 전용의 네트워크"라는 말에서도 알 수 있듯이, SAN 스위치가 장비가 필요하다.
  - 프로토콜
    - Fiber channel
    - FCoE (FC over Ethernet)
    - iSCSI

- 구조를 보자면

![vM1bu](https://user-images.githubusercontent.com/19552819/98459152-57d40800-21db-11eb-8f32-f3b8925b9c2c.png)
