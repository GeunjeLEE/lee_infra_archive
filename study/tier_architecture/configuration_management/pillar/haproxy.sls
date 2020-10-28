web_servers:
    - ip: 192.168.56.12
    - ip: 192.168.56.13

keepalived:
    vip: 172.22.1.103/22
    hosts:
        haproxy:
            state: MASTER
            priority: 101
        haproxy2:
            state: BACKUP
            priority: 100