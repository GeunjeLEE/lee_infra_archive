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

npm_install:
    npm.installed:
        - names:
            - express
            - mysql
        - dir: /home/lee_sample_node_app

forever_install:
    npm.installed:
        - names:
            forever