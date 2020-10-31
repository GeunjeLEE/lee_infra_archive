pkg_install:
  pkg.installed:
    - names:
      - wget
 
create_prometheus_user:
  user.present:
    - name: prometheus
    - createhome: False
    - shell: /sbin/false
    - require: 
      - pkg: pkg_install

/etc/prometheus:
  file.directory:
    - user: prometheus
    - group: prometheus
    - require: 
      - user: create_prometheus_user

/var/lib/prometheus:
  file.directory:
    - user: prometheus
    - group: prometheus
    - require: 
      - file: /etc/prometheus

prometheus-2.14.0.linux-amd64.tar.gz:
  archive.extracted:
    - name: /tmp/
    - source: https://github.com/prometheus/prometheus/releases/download/v2.14.0/prometheus-2.14.0.linux-amd64.tar.gz
    - source_hash: md5=1124545debb407b0bc06b4700bee2a68
    - tar_options: V
    - archive_format: tar
    - if_missing: /usr/local/bin/prometheus
    - require: 
      - file: /var/lib/prometheus

/usr/local/bin/prometheus:
  file.copy:
    - source: /tmp/prometheus-2.14.0.linux-amd64/prometheus
    - user: prometheus
    - group: prometheus
    - require: 
      - archive: prometheus-2.14.0.linux-amd64.tar.gz

/usr/local/bin/promtool:
  file.copy:
    - source: /tmp/prometheus-2.14.0.linux-amd64/promtool
    - user: prometheus
    - group: prometheus
    - require: 
      - file: /usr/local/bin/prometheus

conoles_copy_to_/etc/prometheus:
  file.copy:
    - name: /etc/prometheus
    - source: /tmp/prometheus-2.14.0.linux-amd64/consoles
    - user: prometheus
    - group: prometheus
    - require: 
      - file: /usr/local/bin/promtool

console_libraries_copy_to_/etc/prometheus:
  file.copy:
    - name: /etc/prometheus
    - source: /tmp/prometheus-2.14.0.linux-amd64/console_libraries
    - user: prometheus
    - group: prometheus
    - require: 
      - file: conoles_copy_to_/etc/prometheus

/etc/systemd/system/prometheus.service:
  file.managed:
    - source: salt://prometheus/files/prometheus.service.tmpl
    - user: prometheus
    - group: prometheus
    - require: 
      - file: console_libraries_copy_to_/etc/prometheus

systemd-reload:
  cmd.run :
    - name : systemctl --system daemon-reload
    - require: 
      - file: /etc/systemd/system/prometheus.service

prometheus:
  service.running:
    - enable: True
    - require: 
      - cmd: systemd-reload
