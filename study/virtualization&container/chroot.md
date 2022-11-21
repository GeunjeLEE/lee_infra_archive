## chroot

참고
- https://www.44bits.io/ko/post/change-root-directory-by-using-chroot
- https://www.44bits.io/ko/post/static-compile-program-on-chroot-and-docker-scratch-image

chroot = change root directory
즉, 루트를 변경한다는 것.

루트 디렉토리를 변경하는 리눅스 명령어(시스템 콜)
임의의 디렉토리를 루트 디렉토리로써 인식하여 프로세스를 실행할 수 있다.
프로세스를 실행하기 위한 의존성 패키지 들이 새로운 루트 아래에 준비되어있어야 실제로 사용 가능.

네임스페이스, cproup, 유니온 마운트를 비롯한 컨테이너를 구현하기 위한(격리된 프로세스를 생성하기 위한) 여러가지 기능이 있지만,
그 중에서도 가장 오래되고 기본이 되는 것은 프로세스가 실행되는 루트를 변경하는 일이다.

chroot는 단순하게 아래와 같이 사용한다.
```
chroot --help
Usage: chroot [OPTION] NEWROOT [COMMAND [ARG]...]
or:  chroot OPTION
```

루트 디렉터리를 변경한다는 것은, 특정 프로세스가 상위 디렉터리에 접근할 수 없도록 격리 시킨다는 것이다.

그렇다면...
`chroot /tmp/new_root /bin/bash` /tmp/new_root를 루트 디렉토리로 /bin/bash를 실행한다.

이때 /bin/bash는 기존의 루트 디렉토리가 아닌 새로운 루트 디렉터리에서 부터의 경로이므로
새로운 루트 디렉토리에 /bin/bash가 있어야한다.

또한 /bin/bash의 의존성 패키지도 함께 존재해야 무사히 실행할 수 있으므로
/bin/bash의존성 패키지도 모두 가져온다.

```
ldd로 의존 패키지 확인 후
$ ldd /bin/bash
        linux-vdso.so.1 (0x00007ffe988fb000)
        libtinfo.so.5 => /lib/x86_64-linux-gnu/libtinfo.so.5 (0x00007f1a60cd2000)
        libdl.so.2 => /lib/x86_64-linux-gnu/libdl.so.2 (0x00007f1a60ace000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f1a606dd000)
        /lib64/ld-linux-x86-64.so.2 (0x00007f1a61216000)
```

```
관련 패키지를 모두 복사해온다.
$ mkdir -p /tmp/new_root/lib/x86_64-linux-gnu/ /tmp/new_root/lib64
$ cp /lib/x86_64-linux-gnu/libtinfo.so.5 /tmp/new_root/lib/x86_64-linux-gnu/
$ cp /lib/x86_64-linux-gnu/libdl.so.2 /tmp/new_root/lib/x86_64-linux-gnu/
$ cp /lib/x86_64-linux-gnu/libc.so.6 /tmp/new_root/lib/x86_64-linux-gnu/
$ cp /lib64/ld-linux-x86-64.so.2 /tmp/new_root/lib64
```

```
그 후 실행
$ chroot /tmp/new_root /bin/bash
bash-4.4# <- 정상 실행
```

## 정적 링크 프로그램을 chroot와 도커(Docker) scratch 이미지로 실행하기

hello.c 파일을 hello로 컴파일 후 실행.

```
$ gcc -o hello hello.c
$ ./hello
Hello, world! <- 정상출력됨.
```

### 동적 링크 프로그램을 chroot로 실행
hello를 chroot로 실행하기

```
$ chroot $(pwd) /hello
chroot: failed to run command ‘/hello’: No such file or directory
```

hello 파일이 없다는 에러 메시지가 출력된다.

이는 앞서 bash를 실행하면서도 확인했던 에러 메시지이다.

동일하게, ldd 명령어로 동적 링크된 파일들을 확인하여 관련 패키지를 가져오도록 한다.

```
의존성 패키지 확인 후
$ ldd hello
        linux-vdso.so.1 (0x00007ffcf3266000) <-가상 라이브러리이므로 무시.
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f6965db8000)
        /lib64/ld-linux-x86-64.so.2 (0x00007f69663ab000)
```

```
관련 패키지를 가져온다.
$ mkdir -p ./lib/x86_64-linux-gnu/ ./lib64
$ cp /lib/x86_64-linux-gnu/libc.so.6 ./lib/x86_64-linux-gnu/
$ cp /lib64/ld-linux-x86-64.so.2 ./lib64
$ tree .
.
├── hello
├── hello.c
├── lib
│   └── x86_64-linux-gnu
│       └── libc.so.6
└── lib64
    └── ld-linux-x86-64.so.2
```

다시 chroot를 사용해 hello를 실행.

```
$ chroot $(pwd) /hello
Hello, World! <- 정상 출력
```

### 동적 링크 프로그램을 scratch 이미지로 만들기

같은 프로그램을 도커 이미지로 만들기.

먼저. dockerfile로 이미지 정의
```
FROM ubuntu:latest
ADD hello /hello
CMD /hello
```
그 후 build하여 컨테이너 실행

```
$ docker build -t ubuntu:hello .
$ docker run -it ubuntu:hello
Hello, world!
```

도커에서는 이럴 때 사용할 수 있도록 scratch라는 특별한 이미지를 제공하고 있는데,
scratch는 아무런 파일이 존재하지 않는 비어있는 이미지.

그렇기 때문에 chroot와 마찬가지로, 관련 의존성 패키지를 같이 패키징한다.

```
FROM scratch
ADD lib /lib
ADD lib64 /lib64
ADD hello /hello
CMD ["/hello"]
```

그 후 build & run

```
$ docker build -t scratch:hello .
$ docker run -it scratch:hello
Hello, world! <- 정상 출력.
```

### 정적 링크 프로그램을 chroot로 실행
동적 링크로 컴파일한 프로그램의 경우 동적 라이브러리 파일을 함께 준비해야하는 번거로움이 있다. 

이를 좀 더 개선하는 것으로.
스테틱 링크로 컴파일하는 경우 동적 라이브러리들이 바이너리에 모두 포함된다.
-> 의존성 패키지에 있는 코드들이 같이 바이너리로 컴파일 되는 것 인가?

gcc의 --static 옵션 하나면 정적 링크로 컴파일하는 것이 가능.

hello.c 파일을 정적 링크 컴파일하고 실행보기.

```
$ gcc --static -o hello hello.c
$ ./hello
Hello, world!
```

이 파일에 대해서 ldd를 실행해보면
```
$ ldd ./hello
        not a dynamic executable
```
dynamic executable이 아니란다.

그렇다면

### 정적 링크 프로그램을 scratch 이미지로 만들기

위에서 만든 정적 프로그램을 build하도록 dockerfile 수정
```
FROM scratch
ADD hello /hello
CMD ["/hello"]
```

그 후 build & run
```
$ docker build -t scratch:hello2 .
$ docker run -it scratch:hello2
Hello, world!
```

## 명심해야할 포인트
도커는 서버 가상화와 같이 에뮬레이트 되는 것이 아니라
호스트 서버에서 리소스를 격리하여 어플리케이션(프로세스)을 실행하는 것을 목표로 한다.