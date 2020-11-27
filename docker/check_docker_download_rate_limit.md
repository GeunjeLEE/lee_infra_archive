## Docker hub 제한 내용
참고 : https://www.docker.com/increase-rate-limits

2020 년 11 월 20 일에 Docker Hub의 익명 및 무료 인증 사용에 대한 비율 제한이 적용되었습니다. <br>
익명 및 무료 Docker Hub 사용자는 6 시간당 100 개 및 200 개의 컨테이너 이미지 가져 오기 요청으로 제한됩니다.

- 익명 사용의 경우 6 시간당 100 개의 컨테이너 이미지 요청의 비율 제한이 적용됩니다. 
- 무료 Docker 계정의 경우 6 시간당 200 개의 컨테이너 이미지 요청의 비율 제한이 적용됩니다. 

이러한 제한을 초과하는 이미지 요청은 6 시간이 경과 할 때까지 거부됩니다.

이러한 변경 사항의 영향을받는 경우 다음 오류 메시지가 표시됩니다.
```
ERROR: toomanyrequests: Too Many Requests.

또는

You have reached your pull rate limit.
You may increase the limit by authenticating and upgrading: https://www.docker.com/increase-rate-limits.
```

또한, 인증되지 않은 (익명) 사용자는 IP를 통해 제한이 적용됩니다.

참고 :https://docs.docker.com/docker-hub/download-rate-limit/

## 현재 Docker 풀 속도 제한 및 상태 확인

참고 : https://www.docker.com/blog/checking-your-current-docker-pull-rate-limits-and-status/

Docker Hub에 대한 요청은 이제 제한에 포함되는 요청에 대한 응답 헤더에 속도 제한 정보를 포함합니다. 
- RateLimit-Limit    
  - The RateLimit-Limit header contains the total number of pulls that can be performed within a six hour window.
  - RateLimit-Limit 헤더는 6시간 내에 수행할 수 있는 pull의 총 수를 포함.
- RateLimit-Remaining
  - The RateLimit-Remaining header contains the number of pulls remaining for the six hour rolling window. 
  - RateLimit-Limit 헤더는 6시간 내에 남아있는 pull의 총 수를 포함.

### Anonymous Requests 확인
1. 다음 명령은 auth.docker.io에 ratelimitpreview/test 이미지에 대한 인증 토큰을 요청합니다.
```
$ TOKEN=$(curl "https://auth.docker.io/token?service=registry.docker.io&scope=repository:ratelimitpreview/test:pull" | jq -r .token)

[토큰 내부]
jwt decode $TOKEN
Token header
------------
{
  "typ": "JWT",
  "alg": "RS256"
}

Token claims
------------
{
  "access": [
    {
      "actions": [
        "pull"
      ],
      "name": "ratelimitpreview/test",
      "parameters": {
        "pull_limit": "100", ★
        "pull_limit_interval": "21600" ★
      },
      "type": "repository"
    }
  ],
  ...
}
```
2. 테스트 이미지 ratelimitpreview/test를 요청하고 위의 TOKEN을 전달합니다.(GET 대신 HEAD 요청을 전송)
```
$ curl --head -H "Authorization: Bearer $TOKEN" https://registry-1.docker.io/v2/$IMAGE/manifests/latest
HTTP/1.1 200 OK
Content-Length: 2782
Content-Type: application/vnd.docker.distribution.manifest.v1+prettyjws
...
Date: Fri, 27 Nov 2020 07:06:41 GMT
Strict-Transport-Security: max-age=31536000
RateLimit-Limit: 100;w=21600 ★ 제한
RateLimit-Remaining: 95;w=21600 ★ 남은 횟수
```

### Authenticated requests 확인
1. 인증 된 요청의 경우 토큰을 인증 된 토큰으로 업데이트해야합니다. (이후는 동일)
```
$ TOKEN=$(curl --user 'username:password' "https://auth.docker.io/token?service=registry.docker.io&scope=repository:ratelimitpreview/test:pull" | jq -r .token)
```

## 모니터링 스크립트 & 통합
참고 : https://about.gitlab.com/blog/2020/11/18/docker-hub-rate-limit-monitoring/

위의 curl 명령어는 HTTP 요청과 더 나은 response parsing을 위해 프로그래밍 언어로 전환 될 수 있습니다.
알고리즘은 다음 단계를 따라야합니다.

- Docker Hub에서 인증 토큰 획득
  - 사용자 이름 / 암호 자격 증명을 선택적으로 제공
  - 그렇지 않으면 요청이 익명으로 발생
- HEAD 요청을 도커 허브 레지스트리에 요청 하고 docker pull 요청을 시뮬레이트
- 응답 헤더를 분석하고, RateLimit-Limit와 RateLimit-Remaining 대한 값을 추출 
- 응답 값의 summary를 표시

스크립트 : https://gitlab.com/gitlab-com/marketing/corporate_marketing/developer-evangelism/code/check-docker-hub-limit

위 내용을 따라 만든 스크립트가 Check Docker Hub Limit

Install(centos)
```
(clone this repository)

yum makecache

yum -y install python3 python3-pip

pip3 install -r requirements.txt
```

Usage
```
usage: check_docker_hub_limit.py [-h] [-w WARNING] [-c CRITICAL] [-v] [-t TIMEOUT]

Version: 2.0.0

optional arguments:
  -h, --help            show this help message and exit
  -w WARNING, --warning WARNING
                        warning threshold for remaining
  -c CRITICAL, --critical CRITICAL
                        critical threshold for remaining
  -v, --verbose         increase output verbosity
  -t TIMEOUT, --timeout TIMEOUT
                        Timeout in seconds (default 10s)
```

만약, User 자격 증명을 사용하려면, 환경변수에 docker user/password를 설정
```
export DOCKERHUB_USERNAME='xxx'
export DOCKERHUB_PASSWORD='xxx'
```

export : https://gitlab.com/gitlab-com/marketing/corporate_marketing/developer-evangelism/code/docker-hub-limit-exporter

Check Docker Hub Limit와 같은 스크립트를 바탕으로 만든 Prometheus exporter가 docker-hub-limit-exporter

잘은 모르겠지만 
- https://auth.docker.io/token?service=registry.docker.io&scope=repository:ratelimitpreview/test:pull으로 토큰 취득 요청
- https://registry-1.docker.io/v2/ratelimitpreview/test/manifests/latest로 registry_limits 요청
- 응답 헤더에서 "RateLimit-Limit"와 "RateLimit-Reset"추출
- collect로 수집