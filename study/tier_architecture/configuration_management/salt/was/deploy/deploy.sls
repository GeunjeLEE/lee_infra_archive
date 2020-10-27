pkg_install:
    pkg.installed:
      - names:
        - git
        - nodejs

get_nodejs_webapp_src:
    git.latest:
        - name: https://github.com/LeekeunJe/lee_sample_node_app.git
        - target: /home/
        - branch: master
        - require: 
            - pkg: pkg_install


npm_install:
    npm.installed:
        - names:
            - express
            - mysql
        - dir: /home/lee_sample_node_app
        - require: 
            - git: get_nodejs_webapp_src

forever_install:
    npm.installed:
        - names:
            - forever
        - require: 
            - git: get_nodejs_webapp_src