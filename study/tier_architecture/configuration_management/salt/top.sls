base:
    'roles:web':
        - match: grain
        - web
    'roles:was':
        - match: grain
        - was
    'roles:haproxy':
        - match: grain
        - haproxy
    'roles:monitoring':
        - match: grain
        - prometheus
        - exporter
    'roles:exporter':
        - match: grain
        - exporter

