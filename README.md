# 프로젝트명
> 본 프로젝트는 플래시 메모리 상에서의 파일 시스템에 따른 DBMS 성능을 실험한다. 또한, discard 명령이 파일 시스템의 성능에 끼치는 영향을 연구한다.

플래시 메모리에서 FFS(Ext4, XFS)와 LFS(F2FS)의 사용에 따른 DBMS(MySQL/RocksDB) OLTP(벤치마크 툴: TPC-C, YCSB) 성능을 비교한다.

![](../header.png)

## 배경 지식

### 플래시 메모리
플래시 메모리는 Block들로 구성되며, Block은 다시 Page들로 구성된다. 플래시 메모리에서의 읽기(Read)와 쓰기(Write)는 Page 단위로 실행된다. 또한, 플래시 메모리의 Page는 덮어쓰기가 불가능하다. 따라서 한번 'stale' 상태가 된 Page는 반드시 삭제(Erase)를 거쳐 'free' 상태로 전이된 후 다시 쓰기가 가능하다. 그러나 삭제는 단일 Page가 아닌, Block 단위의 삭제만 가능하다. 삭제 명령은 SSD가 'free' 공간이 필요할 때 Garbage-Collection을 실행할 때 사용된다.  
  
즉, Page 단위의 읽기/쓰기와 다르게 Block 단위의 삭제가 일어남으로써 삭제 대상 Block의 유효한 Page를 다른 Block으로 복사할 필요가 있는데, 이를 '카피백'(Copy-Back)이라 한다. 이러한 카피백으로 인해 '쓰기 증폭' (Write-Amplification) 현상이 발생한다. 쓰기 증폭 정도(Write-Amplification Factor, WAF)는 SSD의 성능에 큰 영향을 끼친다. 또한 SSD는 FTL(Flash Translation Layer)를 통해 HDD와 동일한 인터페이스를 제공한다.  

(참조: https://tech.kakao.com/2016/07/15/coding-for-ssd-part-3/
### MySQL

### TPC-C

### RocksDB

### YCSB

### 파일 시스템
* FFS: Fast File System. 하드디스크의 실린더 개념을 활용하여 실린더 그룹 (블록 그룹)으로 나누어 파일을 저장한다. In-Place update 정책을 사용한다. 대표적인 FFS로 Ext4와 XFS가 있다.
* LFS: Log-Structured File System. In-Place update가 아닌, 로그 구조로 파일을 저장한다. 따라서 Garbage-Collection이 요구되며, 이로 인해 Logical WAF가 높다. 대표적인 LFS로 F2FS가 있다.

### 성능 측정 지표
* Physical WAF: SSD 계층에서의 쓰기 증폭 정도. 실험 시간 전체의 WAF인 Cumulative WAF와 특정 시간(eg.5분) 간격의 WAF인 Run WAF가 있다. 일반적으로 해당 수치가 높을수록 성능의 저하가 심한 경향을 보인다. 그러나 discard가 너무 자주 일어나게 된다면, WAF가 낮아지더라도 오히려 discard의 오버헤드로 인해 성능 저하가 일어날 가능성이 있다.
* Logical WAF: 파일 시스템 계층에서의 쓰기 증폭 정도. 일반적으로 LFS에서 측정하며, 해당 수치가 높을수록 성능의 저하가 심한 경향을 보인다.
* tpmC: TPC-C에서의 성능 지표. 분당 트랜잭션 처리량을 의미한다.
* OPS: YCSB에서의 성능 지표. 초당 operation 처리량을 의미한다.  
* Undiscard: F2FS가 discard 명령을 내려야 하지만 아직 내리지 못한 페이지 수. 해당 수치가 높게 유지되면 불필요한 카피백이 많이 발생해 성능이 저하될 수 있다.

## 실험 환경
| Type | Specification |
|:-----------:|:----------------------------------------------------------:|
| OS          | Ubuntu 18.04.5 LTS                                         |
| CPU         | Intel(R) Xeon(R) Silver 4216 CPU @ 2.10GHz (Total 32 cores)|
| Memory      | 32GB                                                       |
| Kernel      | 5.4.0-66-generic                                           |
| Data Device *(Optional)* | Intel® Optane™ SSD 900P Series 480GB          |
| Log Device *(Optional)* | Samsung 850 PRO SSD 256GB                     |  


| Type | Configuration |
|:----------------:|:----------------------:|
| DB size          | 2GB (20 warehouse)     |
| Buffer Pool Size | 500MB (25% of DB size) |
| Benchmark Tool   | tpcc-mysql             |
| Runtime          | 1200s                  |
| Connections      | 8                      |

## 쉘 사용법
실험 로그 기록 및 결과 그래프 생성을 위한 쉘의 사용법.  
### hj_nq.sh
쉘 내부의 TEST_NAME 변수를 현재 실험명으로 바꾼 후 실행한다. 실험(벤치마크)를 실행함과 동시에 해당 쉘도 실행한다.
```sh
./hj_nq.sh
```

## 결과 분석 방법


## 프로젝트 정보

학번 - 이름 - github주소 - 이메일

## MySQL , TPC-C 실험

## RocksDB, YCSB 실험

<!-- Markdown link & img dfn's -->
[npm-image]: https://img.shields.io/npm/v/datadog-metrics.svg?style=flat-square
[npm-url]: https://npmjs.org/package/datadog-metrics
[npm-downloads]: https://img.shields.io/npm/dm/datadog-metrics.svg?style=flat-square
[travis-image]: https://img.shields.io/travis/dbader/node-datadog-metrics/master.svg?style=flat-square
[travis-url]: https://travis-ci.org/dbader/node-datadog-metrics
[wiki]: https://github.com/yourname/yourproject/wiki
