/etc/yum.repos.d/grafana.repo:
  file.managed:
    - source: salt://grafana/files/grafana.repo
    - user: root
    - group: root
    - mode: 644

pkg_install_for_grafana:
  pkg.installed:
    - names:
      - grafana

grafana:
  service.running:
    - enable: True
