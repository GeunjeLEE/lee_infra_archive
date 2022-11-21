## 시작
micro service architecture(이하 MSA)는 어플리케이션을 서비스 모음으로 구성하는 아키텍처 스타일이다.<br>
MSA를 보다 잘 이해하려면, 먼저 모놀리틱 아키텍처 스타일에 대해서 알고 가는 것이 좋다.

## Monolithic Architecture(모놀리틱 아키텍처)
모놀리틱 아키텍처는 기존의 전통적인 웹 시스템 개발 스타일로, 하나의 어플리케이션 내에 모든 로직들이 포함되어있다.<br>
즉, 특정한 기능을 수행하는 기능인 컴포넌트가 모두 하나의 어플리케이션에 포함되어있는 구조이다.

온라인 쇼핑몰을 예로, 사용자 관리, 상품 관리, 주문 관리, UX 로직 등의 모든 컴포넌트가 하나의 어플리케이션에 들어있는 구조이다.

### 장점
전체 기능을 하나의 어플리케이션으로 처리하기 때문에, <br>
하나의 어플리케이션만 개발하면 되고 배포 역시 하나의 어플리케이션만 수행하면 되기 때문에 편리하다.

### 단점
작은 크기의 애플리케이션에서는 용이 하지만, 규모가 큰 애플리케이션에서는 불리한 점이 많다.

- 시스템이 커지면 커질수록 시스템 전체의 구조와 영향도 파악를 하는 것에 어려움을 겪는다.
- 또한, 빌드/테스트/배포에 시간이 많이 소요된다.
- 특정 컴포넌트를 수정하더라도 전체 어플리케이션을 빌드/배포해야므로 잦은 배포가 필요한 시스템의 경우 불리하다.
- 특정 컴포넌트의 장애가 서비스 전체에 영향을 주게 된다.

## Micro Service Architecture(마이크로 서비스 아키텍처)
MSA는 어플리케이션을 서비스 모음으로 구성하는 아키텍처 스타일이다.<br>
어플리케이션에서 각 컴포넌트(*)를 서비스라는 개념으로 나누어 구성한 아키텍처라 할 수 있다.<br>
각각의 서비스는 상호 독립적으로 동작하며 REST API와 같은 표준 인터페이스로 기능을 제공한다.

* 컴포넌트 : 여러 개의 프로그램 함수들을 모아 하나의 특정한 기능을 수행할 수 있도록 구성한 작은 기능적 단위

### 장점
각각의 독립적인 서비스로 나누어 구성되므로

- 부분적으로 시스템를 확장(Scale out)할 수 있다.
- 독립적으로 빌드/테스트/배포가 가능하다.
- 각 서비스를 담당하는 팀은 다른 팀에 영향을 주지않고 작업할 수 있다.
- 서비스에 장애가 발생했을 때, 해당 서비스를 격리하여 전체 서비스에 영향을 주지 않도록 할 수 있다.

### 단점

- 테스트의 어려움
  - 서비스 간의 상호 작용 고려하여 테스트하는 것이 어렵다
- 기능별로 데이터가 분산되기 때문에 데이터의 정합성을 관리하기 어렵다.
  - 또한 서비스간 트렌젝션 처리에도 어려움이 있다.
    - 예를 들어 입/출금 서비스에서 어느 한쪽이 장애가 났을경우 등..
- 서비스 팀의 능력과 전체 팀의 능력 차이
  - 개발경험이 없는 팀이 전체 팀의 개발 속도를 못 따라오고 품질 등에도 문제가 생긴다.
- 메모리 소비 증가
  - MSA는 각 서비스를 독립된 서버에 분할 배치하기 때문에 중복되는 모듈에 대해서 그만큼 메모리 사용량이 늘어난다.
    - N개의 모놀리식 애플리케이션 인스턴스를 NxM 서비스 인스턴스로 대체하기 때문에.

MSA의 경우, 금융이나 제조와 같이 트렌젝션 보장이 중요한 엔터프라이즈 시스템보다는 <br>
대규모 처리가 필요한 B2C 형 서비스에 적합하기 때문에 아키텍쳐 스타일 자체가 트렌젝션을 중요시하는 시나리오에서는 적절하지 않다.

## (개인적으로)그렇다면.. MSA vs N-tier Architecture
MSA와 N-tier는 뭐가 다를까?

MSA는 어플리케이션이 어떻게 구성되고, 어떤 구성요소(서비스)가 있고 각 서비스는 어떻게 통신하며<br>
어떻게 개발되고 어떻게 배포되는 것 인지에 대한 것을 중점으로 둔 아키텍처?

N-tier는 시스템 계층 구조 대한 것을 중점을 둔 것으로<br>
Presentation, Business, Data의 논리적인 계층 구조에 대한 것을 중점으로 둔 아키텍처?

계층을 나누지 않고 MSA로 구성할 수 있고 계층을 나누어 MSA로 구성할 수 있다?

아니면 N-tier에서 점차 SOA, MSA로 발전한 형태?


## 참고
https://microservices.io/
https://microservices.io/patterns/microservices.html
https://bcho.tistory.com/948

- 개발자는 분산 시스템을 만드는 데 따르는 추가적인 복잡성을 처리해야합니다.
  - 개발자는 서비스 간 통신 메커니즘을 구현하고 부분적인 오류를 처리해야합니다.
  - 여러 서비스에 걸친 요청을 구현하는 것이 더 어렵습니다.
  - 서비스 간의 상호 작용을 테스트하는 것이 더 어렵습니다.
  - 여러 서비스에 걸친 요청을 구현하려면 팀 간의 신중한 조정이 필요합니다.
  - 개발자 도구 / IDE는 모 놀리 식 애플리케이션 구축을 지향하며 분산 애플리케이션 개발에 대한 명시적인 지원을 제공하지 않습니다.
- 배포 복잡성. 프로덕션 단계에서는 다양한 서비스로 구성된 시스템을 배포하고 관리하는 작업의 복잡성도 있습니다.
- 메모리 소비 증가. 마이크로 서비스 아키텍처는 N 개의 모놀리식 애플리케이션 인스턴스를 NxM 서비스 인스턴스로 대체합니다. 
  - 각 서비스가 일반적으로 인스턴스를 격리하는 데 필요한 자체 JVM (또는 이와 동등한)에서 실행되는 경우 JVM 런타임보다 M배 많은 오버헤드가 발생합니다. 
    - 또한 Netflix의 경우와 같이 각 서비스가 자체 VM (예 : EC2 인스턴스)에서 실행되는 경우 오버헤드가 훨씬 더 높습니다.