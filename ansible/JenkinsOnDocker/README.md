# jenkins

Ansible と Docker を使用して Jenkins コンテナを作成

## Vagrant を使用した動作確認方法

1. VMを起動する

    ```bash
    $ vagrant up
    ```

2. VMにログインする

    ```bash
    $ vagrant ssh
    ```

3. Ansibleをインストールする

    ```bash
    $ sudo /vagrant/scripts/bootstrap-ansible.sh
    ```

4. playbooks ディレクトリに移動する

    ```bash
    $ cd /vagrant/playbooks
    ```

5. Dockerをインストールする

    ```bash
    $ ansible-playbook install-docker.yml
    ```

6. Jenkinsコンテナを立ち上げる

    ```bash
    $ ansible-playbook launch_jenkins.yml
    ```

