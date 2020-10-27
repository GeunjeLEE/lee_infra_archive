deploy_app:
    cmd.run:
        - name: git checkout master; git pull
        - cwd: /home/lee_sample_node_app
