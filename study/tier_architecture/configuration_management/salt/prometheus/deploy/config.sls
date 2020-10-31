/etc/prometheus/prometheus.yml:
    file.managed:
        - source: salt://prometheus/files/prometheus.yml.tmpl
        - user: prometheus
        - group: prometheus
        - template: jinja
        - context:
            node_exporter_targets: {{ pillar['node_exporter_targets'] }}