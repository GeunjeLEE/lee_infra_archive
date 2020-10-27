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