git_tool_install:
    cmd.run:
        - name: sudo yum install git -y

get_wep_app:
    cmd.run:
        - name: git clone https://github.com/LeekeunJe/lee_sample_node_app.git
        - cwd: /home/

npm_install:
    cmd.run:
        - name: npm install
        - cwd: /home/lee_sample_node_app

forever_install:
    cmd.run:
        - name: npm install forever -g
        - cwd: /home/lee_sample_node_app
