# 프로젝트명
> 본 프로젝트는 플래시 메모리 상에서의 파일 시스템에 따른 DBMS 성능을 실험한다. 또한, discard 명령이 파일 시스템의 성능에 끼치는 영향을 연구한다.

플래시 메모리에서 FFS(Ext4, XFS)와 LFS(F2FS)의 사용에 따른 DBMS(MySQL/RocksDB) OLTP(벤치마크 툴: TPC-C, YCSB) 성능을 비교한다.

![](../header.png)

## 배경 지식

### 플래시 메모리
플래시 메모리는 Block들로 구성되며, Block은 다시 Page들로 구성된다. 플래시 메모리에서의 읽기(Read)와 쓰기(Write)는 Page 단위로 실행된다. 또한, 플래시 메모리의 Page는 덮어쓰기가 불가능하다. 따라서 한번 'stale' 상태가 된 Page는 반드시 삭제(Erase)를 거쳐 'free' 상태로 전이된 후 다시 쓰기가 가능하다. 그러나 삭제는 단일 Page가 아닌, Block 단위의 삭제만 가능하다. 삭제 명령은 SSD가 'free' 공간이 필요할 때 Garbage-Collection을 실행할 때 사용된다.  
즉, Page 단위의 읽기/쓰기와 다르게 Block 단위의 삭제가 일어남으로써 '쓰기 증폭' (Write-Amplification) 현상이 발생한다. 

### MySQL

### TPC-C

### RocksDB

### YCSB

### 파일 시스템

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
