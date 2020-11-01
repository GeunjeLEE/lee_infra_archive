## 배포
SaltStack을 이용하여, 서버가 state에 정의한 상태(state)가 되도록 한다.<br>
멱등성의 성질을 가지고 있으므로, 몇 번을 배포하더라도 항상 동일한 형태가 된다.

saltstack의 grains를 이용하여 노드에 역할을 부여하고, 
정의된 state 템플릿을 배포했을때 역할에 따른 상태로 변경될 수 있도록 한다.

#### roles 추가 설정은
```
salt 'target' cmd.run 'echo "  - new_role" >> /etc/salt/grains'
salt 'target' saltutil.refresh_grains
```

### HAproxy 배포
- 전체 배포
```
salt -G 'roles:haproxy' state.apply haproxy.deploy test=True
salt -G 'roles:haproxy' state.apply haproxy.deploy 
```

- 설정 배포
```
salt -G 'roles:haproxy' state.apply haproxy.deploy.config test=True
salt -G 'roles:haproxy' state.apply haproxy.deploy.config
```

### WEB(Nginx) 배포
- 전체 배포
```
salt -G 'roles:web' state.apply web.deploy test=True
salt -G 'roles:web' state.apply web.deploy 
```

- 설정 배포
```
salt -G 'roles:web' state.apply web.deploy.config test=True
salt -G 'roles:web' state.apply web.deploy.config
```

### WAS(Nodejs) 배포

- nodejs 초기 설치 시 선행
```
salt -G 'roles:was' state.apply was.deploy.nodejs_setup test=True
salt -G 'roles:was' state.apply was.deploy.nodejs_setup 
```
- 전체 배포
```
salt -G 'roles:was' state.apply was.deploy test=True
salt -G 'roles:was' state.apply was.deploy 
```
- app 배포
```
salt -G 'roles:was' state.apply was.deploy.deploy test=True
salt -G 'roles:was' state.apply was.deploy.deploy
```
- web app 실행
```
salt -G 'roles:was' cmd.run 'forever start /home/lee_sample_node_app/app.js'
```

### prometheus 배포
- 전체 배포
```
salt -G 'roles:monitoring' state.apply prometheus.deploy test=True
salt -G 'roles:monitoring' state.apply prometheus.deploy
```

- 설정(prometheus.yml) 배포
```
salt -G 'roles:monitoring' state.apply prometheus.deploy.config test=True
salt -G 'roles:monitoring' state.apply prometheus.deploy.config
```

## exporter 배포
```
salt -G 'roles:exporter' state.apply exporter.deploy test=True
salt -G 'roles:exporter' state.apply exporter.deploy
```

### Grafana 배포
```
salt -G 'roles:monitoring' state.apply grafana test=True
salt -G 'roles:monitoring' state.apply grafana
```
