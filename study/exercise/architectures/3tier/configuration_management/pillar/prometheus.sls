node_exporter_targets:
    - name: haproxy
      ips:
        - 192.168.56.11
        - 192.168.56.17
    - name: web
      ips:
        - 192.168.56.12
        - 192.168.56.13
    - name: was
      ips:
        - 192.168.56.14
        - 192.168.56.15
    - name: db
      ips:
        - 192.168.56.16
        - 192.168.56.18
    - name: prometheus_master
      ips:
        - 192.168.56.19     