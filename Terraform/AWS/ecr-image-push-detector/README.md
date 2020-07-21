## 개요
ECR 레포지토리에 push되는 이미지의 취약성 검사 결과를 Slack에 통지

### 생성되는 리소스
- cloudwatch event rule
- lambda
  - iam role for logging

## 구축 & 사용 방법
1. terraform으로 필요한 리소스 배포
```
$ terraform init
$ terraform plan
$ terraform apply
```

2. lambda 함수 콘솔에서 webhook url을 추가.
```
comming soon
```

### 참고
- ECR 레포지토리에 이미지를 Push할때 자동으로 Scan하도록 설정되어있어야함(scan on push)
- 기본적으로 [모든 repository에 대한 스캔결과](https://github.com/LeekeunJe/infra_archvie/blob/master/Terraform/ecr-image-push-detector/module/cloudwatch_event_rule/main.tf#L6)를 통지하도록 되어있음.
  - 레포지토리를 특정하고 싶은 경우, cloudWatch의 이벤트 소스에서 [이벤트 패턴](https://docs.aws.amazon.com/ko_kr/codepipeline/latest/userguide/create-cwe-ecr-source-console.html)을 수정해야함
