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


## 실험 환경

스크린 샷과 코드 예제를 통해 사용 방법을 자세히 설명합니다.

_더 많은 예제와 사용법은 [Wiki][wiki]를 참고하세요._

## 쉘 사용법

모든 개발 의존성 설치 방법과 자동 테스트 슈트 실행 방법을 운영체제 별로 작성합니다.

```sh
make install
npm test
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
