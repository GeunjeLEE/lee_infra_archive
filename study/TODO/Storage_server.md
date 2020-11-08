# 스토리지 서버
## 서버와 스토리지를 연결하는 방법으로는
- DAS/Direct Attached Storege
  - 서버에 직접 저장장치를 연결한다.
  - 블록 레벨 액세스
  - 프로토콜
    - ATA・SATA
    - SCSI・SAS
    - Fiber channel


- NAS/Network Attached Storage
  - 스토리지를 기존 네트워크에 연결하고, 네트워크를 통해 서버와 연결한다.
  - 파일 레벨 액세스
    - DB에는 적합하지 않다?
  - 프로토콜
    - CIFS
    - NFS
    - SMB
    - FTP
    - HTTP


- SAN/Storage Area Network
  - 별도의 스토리지 전용의 네트워크를 구축하여 스토리지를 통합하고, 스토리지 네트워크와 연결해 서버와 연결한다.
    - "스토리지 전용의 네트워크"라는 말에서도 알 수 있듯이, SAN 스위치가 장비가 필요하다.
  - 블록 레벨 액세스
  - 프로토콜
    - Fiber channel
    - FCoE (FC over Ethernet)
    - iSCSI

## 비교