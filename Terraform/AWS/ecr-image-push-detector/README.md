### 개요
ECR 레포지토리에 이미지를 업로드 했을 때 발생하는 이미지 취약성 Scan 이벤트를<br>
Cloudwatch로부터 감지하여 Scan 결과를 Slack에 통지한다.

### terraform version
- `>=0.12`

### 생성되는 리소스
- cloudwatch event rule
- lambda

### 생성
1. terraform으로 AWS 리소스 배포
```
$ terraform init
$ terraform plan
$ terraform apply
```

2. AWS 리소스 생성 후, lambda 콘솔에서 environment variable에 Slack web hook url을 추가.

참고 : https://docs.aws.amazon.com/lambda/latest/dg/configuration-envvars.html

## 흐름
<img width="1250" alt="KakaoTalk_20200910_215918544" src="https://user-images.githubusercontent.com/19552819/92732170-0b25a980-f3b1-11ea-8d45-54e5d0afa370.png">

### 참고
- ECR 레포지토리에 이미지를 Push할때 자동으로 Scan하도록 설정되어있어야함(scan on push)
- 기본적으로 [모든 repository에 대한 스캔결과](https://github.com/LeekeunJe/lee_infra_archive/blob/master/Terraform/AWS/ecr-image-push-detector/module/cloudwatch_event_rule/main.tf#L6)를 통지하도록 되어있음.
  - 레포지토리를 특정하고 싶은 경우, cloudWatch의 이벤트 소스에서 [이벤트 패턴](https://docs.aws.amazon.com/ko_kr/codepipeline/latest/userguide/create-cwe-ecr-source-console.html)을 수정해야함
