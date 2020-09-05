### 개요
개발/테스트 환경에서 ECS의 불필요한 가동 시간을 줄이기 위해<br>
Lambda를 이용하여 업무 시간 이외의 시간대에는 ECS의 Task를 종료시킴

### terraform version
- `>=0.12`

### 생성되는 리소스
- cloudwatch event rule
- lambda

### 생성

1. lambda source code에서 대상 ECS Cluster와 Service를 지정

[참고](https://github.com/LeekeunJe/lee_infra_archive/blob/master/Terraform/AWS/reduce_ecs_running_time/src/reduce_ecs_running_time.py#L119)
```
ecs_list = [
    ['ECS_cluster_name','ECS_service_name']
]
```

2. terraform으로 AWS 리소스 배포
```
$ terraform init
$ terraform plan
$ terraform apply
```

### 흐름

![reduce_ecs](https://user-images.githubusercontent.com/19552819/88399556-035e7580-ce02-11ea-8fde-944173abfe54.JPG)

- (※1)
    - ECS cluster의 tag에서 AutoScaling target value를 가져옴
    - AutoScaling target value의 값을 참고하여 대상 ECS Service에 AutoScaling Policy를 생성
        - AutoScaling Policy를 생성 후 ECS Cluster의 tag는 삭제
    - ECS Task 가동

- (※2)
    - ECS Service에 설정되어 있는 AutoScaling policy에서 AutoScaling target value를 취득
    - 취득한 AutoScaling target value를 ECS cluster의 태그에 기록(ECS Task 가동 시, AutoScaling Policy를 생성 할 때 참고하기 위해)
    - ECS Task 정지

### 참고
1. 하나의 ECS Cluster에 하나의 ECS Service가 있는 경우에 한해서 문제없이 실행될 수 있음
2. AutoScaling Policy는 하나일 경우에 한해서 문제없이 실행될 수 있음

### TODO
- ECS Service가 다수 존재할 때에도 문제없이 실행될 수 있도록 수정
- AutoScaling Policy가 다수 존재할 때에도 문제없이 실행될 수 있도록 수정
