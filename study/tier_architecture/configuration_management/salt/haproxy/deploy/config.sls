/etc/haproxy/haproxy.cfg:
    file.managed:
        - source: salt://haproxy/files/haproxy.cfg.tmpl
        - user: root
        - group: root
        - mode: 644
        - template: jinja
        - context:
            backends: {{ pillar['web_servers'] }}
