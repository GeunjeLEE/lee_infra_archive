/etc/yum.repos.d/nginx.repo:
    file.managed:
        - source: salt://web/files/nginx.repo
        - user: root
        - group: root
        - mode: 644
        - template: jinja

nginx:
    pkg.installed
    require:
        - file: /etc/yum.repos.d/nginx.repo
