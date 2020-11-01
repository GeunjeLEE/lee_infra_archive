pkg_install_for_node_exporter:
  pkg.installed:
    - names:
      - wget
 
create_nodexporter_user:
  user.present:
    - name: nodexporter
    - createhome: False
    - shell: /sbin/false
    - require: 
      - pkg: pkg_install

node_exporter-0.18.1.linux-amd64.tar.gz:
  archive.extracted:
    - name: /tmp/
    - source: https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz
    - skip_verify: True
    - tar_options: V
    - archive_format: tar
    - if_missing: /usr/local/bin/node_exporter

/usr/local/bin/node_exporter:
  file.managed:
    - source: /tmp/node_exporter-0.18.1.linux-amd64/node_exporter 
    - user: nodexporter
    - group: nodexporter
    - mode: 755
    - require: 
      - archive: node_exporter-0.18.1.linux-amd64.tar.gz

/etc/systemd/system/node_exporter.service:
  file.managed:
    - source: salt://exporter/files/node_exporter.service.tmpl
    - user: nodexporter
    - group: nodexporter
    - require: 
      - file: /usr/local/bin/node_exporter

systemd_reload_for_node_exporter:
  cmd.run :
    - name : systemctl --system daemon-reload
    - require: 
      - file: /etc/systemd/system/node_exporter.service

node_exporter:
  service.running:
    - enable: True
    - require: 
      - cmd: systemd-reload

