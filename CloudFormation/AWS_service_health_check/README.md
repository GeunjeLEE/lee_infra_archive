## 개요
- [AWS Personal Health Dashboard](https://aws.amazon.com/ko/premiumsupport/technology/personal-health-dashboard/)를 이용해서 자신의 AWS 리소스에 영향을 끼칠 수 있는 이벤트 알림(AWS 장애 등)을 Slack으로 전송
- AWS Personal Health Dashboard는 개인화 된 정보를 제공하기 때문에 특정 AWS 계정에 관한 정보만을 알린다.
    - AWS Region 장애 및 특정 계정 리소스의 업데이트 권고 이벤트 등이 전송됨

### 생성되는 리소스
- AWS Personal Health Dashboar
- AWS Cloudwatch Event Rule
- AWS SNS
- AWS chatbot

### 생성

1. AWS Console에서CloudFormation으로 이동하여、Stack을 생성
2. 스택 생성 화면에서 [템플릿 파일을 업로드]로 template.yaml을 업로드
3. 다음으로 이동하여、[파라미터]에서 `SlackChannelId`와 `SlackWorkspaceId`를 입력
4. 나머지는 Default인 상태로 작성.

## 흐름
<img width="1358" alt="KakaoTalk_20200910_220939092" src="https://user-images.githubusercontent.com/19552819/92733205-61dfb300-f3b2-11ea-9e57-5cc4378490b0.png">

### 참고
- AWS Chatbot에서 Slack 채팅 클라이언트가 연동되어있는지 확인할 것.
    - 연동되어있는 경우 `SlackWorkspaceId`을 확인할 수 있음.
- `SlackChannelId`는 [참고 링크](https://www.wikihow.com/Find-a-Channel-ID-on-Slack-on-PC-or-Mac)에서 확인 방법을 확인

