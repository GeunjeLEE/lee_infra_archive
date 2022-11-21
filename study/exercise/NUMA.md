## NUMA 아키텍쳐
NUMA / Non-Uniformed Memory Access / 불균일 기억장치 접근이라는 뜻이며<br>
멀티 프로세서 환경에서 적용되는 Memory 접근 방식이다.

NUMA와 반대는 개념인 UMA(Uniform Memory Access) 아키텍쳐에서는 모든 Processor가 하나의 공용 BUS를 통해 Memory에 접근한다.<br>
공용 BUS를 이용하는 만큼, 한 소켓에 있는 CPU가 Memory에 접근하는 동안 다른 소켓에 있는 CPU는 Memory에 접근할 수 없다.

NUMA 아키텍쳐의 경우 Processor와 Memory가 Node라는 하나의 그룹을 이루어 Processor는 자신 만의 로컬 Memory를 갖는 구조가 된다.<br>
때문에 각 소켓의 CPU는 Memory에 동시에 접근할 수 있다.

즉, 기존의 구성에서는 각각의 cpu가 메모리에 접근하기 위해 bus를 통해 접근했지만<br>
bus는 동시에 사용할 수 없기 때문에 동시에 메모리에 접근할 수 없었다.

NUMA 아키텍쳐에서는 각각의 로컬 메모리를 사용하면서 동시에 메모리에 접근하게 될 수 있게 되었다.

하지만 로컬 메모리가 부족하면 다른 Node의 메모리로 접근하게 되고<br>
이때 메모리 접근에 시간이 소요되어 성능 저하를 경험하게 된다.

자신의 Node의 메모리에 접근하는 것을 Local Access라고 하고<br>
다른 Node의 메모리에 접근하는 것을 Remote Access라고 한다.