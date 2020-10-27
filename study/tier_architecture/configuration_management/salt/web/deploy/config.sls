/etc/nginx/conf.d/default.conf:
    file.managed:
        - source: salt://web/files/default.conf.tmpl
        - user: root
        - group: root
        - mode: 644
        - template: jinja
        - context:
            backend_ip: {{ pillar['proxy_pass'][grains['host']] }}

nginx:
    service.running:
        - enable: True
