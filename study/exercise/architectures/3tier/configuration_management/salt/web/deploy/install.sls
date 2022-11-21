/etc/yum.repos.d/nginx.repo:
    file.managed:
        - source: salt://web/files/nginx.repo
        - user: root
        - group: root
        - mode: 644

pkg_install:
    pkg.installed:
        - names:
            - nginx
        - require:
            - file: /etc/yum.repos.d/nginx.repo