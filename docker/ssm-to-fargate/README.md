fargate에 ssm-agent를 이용해서 접속하기 위한 dockerfile

ecs fargate는 외부서버로 취급하기 때문에 aws hybrid activation이 필요.

- aws hybrid activation생성 후
    - agent_code / agent_id필요
- ssm-agent를 설치한 docker image로 fargate생성
- ssm-agent resigter로 서버 인증 필요.