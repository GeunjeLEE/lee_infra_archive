pkg_install:
    pkg.installed:
      - names:
        - wget
 
prometheus:
  user.present:
    - createhome: False
    - shell: /sbin/false

/etc/prometheus:
  file.directory:
    - user: prometheus
    - group: prometheus

/var/lib/prometheus:
  file.directory:
    - user: prometheus
    - group: prometheus

prometheus-2.14.0.linux-amd64.tar.gz:
  archive.extracted:
    - name: /tmp/
    - source: https://github.com/prometheus/prometheus/releases/download/v2.14.0/prometheus-2.14.0.linux-amd64.tar.gz
    - source_hash: md5=1124545debb407b0bc06b4700bee2a68
    - tar_options: V
    - archive_format: tar
    - if_missing: /usr/local/bin/prometheus

/usr/local/bin/prometheus:
  file.copy:
    - source: /tmp/prometheus-2.14.0.linux-amd64/prometheus
    - user: prometheus
    - group: prometheus

/usr/local/bin/promtool:
  file.copy:
    - source: /tmp/prometheus-2.14.0.linux-amd64/promtool
    - user: prometheus
    - group: prometheus

/etc/prometheus:
  file.copy:
    - source: /tmp/prometheus-2.14.0.linux-amd64/consoles
    - user: prometheus
    - group: prometheus

/etc/prometheus:
  file.copy:
    - source: /tmp/prometheus-2.14.0.linux-amd64/console_libraries
    - user: prometheus
    - group: prometheus

/etc/systemd/system/prometheus.service:
    file.managed:
        - source: salt://prometheus/files/prometheus.service.tmpl
        - user: prometheus
        - group: prometheus

systemd-reload :
  cmd.run :
   - name : systemctl --system daemon-reload

prometheus:
  service.running:
    - enable: True