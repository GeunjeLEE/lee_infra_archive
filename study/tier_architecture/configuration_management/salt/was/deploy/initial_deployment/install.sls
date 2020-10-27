node_setup:
    cmd.run:
        - name: curl -sL https://rpm.nodesource.com/setup_10.x | sudo bash -

nodejs:
    pkg.installed
