## 개요
systemctl 커맨드 실행시, `connection time out`이 발생

* 로그1
```
$ systemctl list-units
Failed to list units: Connection timed out
```
* 로그2
```
$ systemctl status ceilometer-mongoFailed to list unit files: Connection timed out
Failed to list units: Connection timed out
```

## 원인
* Linux 7.2버전에서 발생하는 버그로 보임.
* rhel7: "Connection time out" message is coming after running "systemctl list-unit-files"
    * https://access.redhat.com/solutions/2407811
```
deamon-reexec was failing with timeout.
After killing,systemctl list-unit-files command was working fine.
```

## 해결
* update `systemd` to `219-19.el7_2.13` or later

### 작업순서
1. update `Systemd` to `219-19.el7_2.13` or later
2. OS reboot

