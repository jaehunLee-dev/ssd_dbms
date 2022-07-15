# 프로젝트명
> 본 프로젝트는 플래시 메모리 상에서의 파일 시스템에 따른 DBMS 성능을 실험한다. 또한, discard 명령이 파일 시스템의 성능에 끼치는 영향을 연구한다.

플래시 메모리에서 FFS(Ext4, XFS)와 LFS(F2FS)의 사용에 따른 DBMS(MySQL/RocksDB) OLTP(벤치마크 툴: TPC-C, YCSB) 성능을 비교한다.

![](../header.png)

## 배경 지식

### 플래시 메모리
플래시 메모리는 Block들로 구성되며, Block은 다시 Page들로 구성된다. 플래시 메모리에서의 읽기(Read)와 쓰기(Write)는 Page 단위로 실행된다. 또한, 플래시 메모리의 Page는 덮어쓰기가 불가능하다. 따라서 한번 'stale' 상태가 된 Page는 반드시 삭제(Erase)를 거쳐 'free' 상태로 전이된 후 다시 쓰기가 가능하다. 그러나 삭제는 단일 Page가 아닌, Block 단위의 삭제만 가능하다. 삭제 명령은 SSD가 'free' 공간이 필요할 때 Garbage-Collection을 실행할 때 사용된다.  
  
즉, Page 단위의 읽기/쓰기와 다르게 Block 단위의 삭제가 일어남으로써 삭제 대상 Block의 유효한 Page를 다른 Block으로 복사할 필요가 있는데, 이를 '카피백'(Copy-Back)이라 한다. 이러한 카피백으로 인해 '쓰기 증폭' (Write-Amplification) 현상이 발생한다. 쓰기 증폭 정도(Write-Amplification Factor, WAF)는 SSD의 성능에 큰 영향을 끼친다. 또한 SSD는 FTL(Flash Translation Layer)를 통해 HDD와 동일한 인터페이스를 제공한다.  

(참조: https://tech.kakao.com/2016/07/15/coding-for-ssd-part-3/)  

### MySQL
MySQL은 가장 많이 쓰이는 오픈 소스 RDBMS이다. MySQL서버는 크게 MySQL 엔진과 스토리지 엔진으로 나누어지는데, MySQL 엔진은 SQL 문장을 분석, 최적화등 클라이언트로부터 오는 요청을 처리하고, 스토리지 엔진은 실제 데이터를 디스크 스토리지에 저장하거나 조회한다. MySQL에 다양한 스토리지 엔진을 사용 가능하지만 그 중에서 B+ Tree기반의 InnoDB 스토리지 엔진이 가장 널리 쓰인다. InnoDB는 메모리 영역과 디스크 영역으로 나누어 진다. 사용자가 DB를 변경한다면 in-place-update방식으로 디스크 영역에 데이터가 쓰인다.

Reference: https://jeong-pro.tistory.com/239

### TPC-C
TPC란 Transaction Processing Performance Council 에서 발표한 벤치마크 모델들이다. TCP는 OLTP 시스템의 처리 성능을 평가하는 기준이 된다. 그 중 TPC-C는 TPC-A 모델이나 TPC-B 모델보다 복잡한 유통업의 수주·발주 OLTP 성능 평가를 위한 벤치마크 모델이다.

### RocksDB
RocksDB는 SSD에 최적화된 Key-Value 형태의 로그 구조 데 이터베이스 엔진이다. RocksDB의 데이터 저장 구조는 Log-Structured Merge Tree(LSM-tree)를 기반으로 한다. RocksDB는 쓰기 요청 시 메모리의 Active Memtable이란 이름의 임시 버퍼에 데이터를 쓴다. 해당 Memtable이 일정 크기가 되면 읽기 전용 Memtable이 되고, 일정 개수 이상의 Memtable이 모이면 저장 장치에 내려가(flush) SST 파일 형태로 저장된다. 따라서 RocksDB는 SST 파일 단위로(기본 64MB) I/O를 진행하고, 데이터를 append-only 로그에 저장함으로써 순차 쓰기를 보장한다.

### YCSB
YCSB(Yahoo! Cloud Serving Benchmark)는 클라우드 서비스와 NoSQL의 성능을 측정하기위한 벤치마크 툴이다. YCSB는 기본적으로 제공하는 다른 작동방식을 가진 workload들이 있다. 또 사용자가 이를 수정하거나 직접 만들어 사용할 수도 있다.  

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
| OS          | Ubuntu 18.04.6 LTS                                         |
| CPU         | Intel(R) Xeon(R) Gold 6248R CPU @ 3.00GHz(total 96 core)   |
| Memory      | 1.56TB                                                     |
| Kernel      | 5.4.0-84-generic                                           |
| Data Device | CT250 MX500 SSD                                            |

## 쉘 사용법
실험 로그 기록 및 결과 그래프 생성을 위한 쉘의 사용법.  
### log_write.sh
쉘 내부의 TEST_NAME 변수를 현재 실험명으로 바꾼 후 실행한다. 실험(벤치마크)를 실행함과 동시에 해당 쉘도 실행한다.
```sh
./log_write.sh
```
  
### waf_cal.sh
smartctl 로그를 통해 WAF 계산을 한다. 247행과 248행, 즉 LBA와 PBA 추출을 하여 이전 Address와의 차이를 계산하여 logical, physical 쓰기의 양을 계산한 후 WAF를 계산한다.
```sh
./waf_cal.sh 실험명_smartctl.log
```  

### trace_plot.sh
blktrace의 읽기/쓰기를 그래프로 만든다. read/write/read&write 총 3개의 그래프가 생성된다.
```sh
./trace_plot.sh ~/result/blktrace/실험명.btrace
```

### graph.sh
실험 결과들을 그래프로 생성해준다. 해당 쉘에 사용하기 위한 실험 결과는, 추가적인 작업이 요구될 수 있다. (awk, grep 등을 이용한 특정 수치 추출 등)
3개의 파일시스템(Ext4,XFS,F2FS)과 같이 여러 실험 결과를 동시에 그려 비교가 가능하다.
```sh
./graph.sh runwaf(ext4) runwaf(xfs) runwaf(f2fs)
```

### rocks_strt.sh
RocksDB - YCSB를 실행하고 결과 파일을 tee를 통해 저장한다. 직접 실행이 아닌, rocks_idle.sh 내부에서 사용된다.

### rocks_idle.sh
idle time을 주는 실험을 위해 YCSB를 실행하고 주기적으로 SIGSTOP을 통해 일시정지 한다. YCSB의 몇분 실행 당 몇분의 idle time을 줄지 코드의 수정을 통해 설정 가능하다.  
```sh
./rocks_idle.sh
```

## 결과 분석 방법
### blktrace
blktrace 결과물의 파싱을 통해 btrace 파일이 생성된다.  
![btrace](https://user-images.githubusercontent.com/86291473/178197051-97663785-4ad7-464a-966b-fbac1507ceae.jpg)  
RWBS
* R - Read
* W - Write
* S (RS,WS,FWFS,FWS) - 파일 시스템에서 Synchronous Operation을 뜻함.
* D - Discard  

### smartctl
smartctl은 physical WAF 측정을 위해 사용된다. 247행과 248행을 통해 WAF 계산이 이루어지며, 247은 LBA, 248은 SSD, 즉 PBA를 뜻한다.
![smartctl_2](https://user-images.githubusercontent.com/86291473/178197976-a4f8b388-45a4-4941-9d59-07d247d7a8b9.jpg)  

### logwaf_streams
cat /proc/fs/f2fs/sdb1/iostat_info 통해 추출한 로그.  
![f2fslog](https://user-images.githubusercontent.com/86291473/178204565-a093ce0e-fcc0-4e5e-8db1-2517cbad84bf.JPG)  
* fs_data: SSD (block device, block layer)에 전달한 write bytes
* TOTAL  = fs_data + fs_node + fs_meta + fs_gc_data/node + fs_cp_data/node/meta
* Logical(Filesystem) WAF = TOTAL / (fs_data)

### logwaf__streams
cat /sys/kernel/debug/f2fs/status 통해 추출한 로그. undiscard 수치를 확인할 수 있다.  
![undiscard](https://user-images.githubusercontent.com/86291473/178204366-f8a6935d-113b-432c-ac0c-f0b8468a4bec.jpg)  

## SSD 초기화 및 File System Mount
0. Data directory 내용 삭제
```sh
rm -rf /path/to/datadir/*
```

1. 기존 SSD Unmount
```sh
sudo umount /dev/[PARTITION]
```

2. SSD Blksidcard
```sh
sudo blkdiscard /dev/[DEVICE]
```

3. 파티션 생성
```sh
sudo fdisk /dev/[DEVICE]
//command: n (new partition), w (write, save)
//Whole SSD in 1 partition
```

4. File system 생성
```sh
//F2FS
sudo mkfs.f2fs /dev/[PARTITION] -f

//Ext4
sudo mkfs.ext4 /dev/[PARTITION] -E discard,lazy_itable_init=0,lazy_journal_init=0 -F

//XFS
sudo mkfs.xfs /dev/[PARTITION] -f
```

5. Data directory에 mount
```sh
//F2FS default
sudo mount /dev/[PARTITION] /path/to/datadir 

//F2FS lfs mode
sudo mount -o mode=lfs /dev/[PARTITION] /path/to/datadir 

///Ext4, XFS
sudo mount -o discard /dev/[PARTITION] /path/to/datadir 
```

6. 권한 설정
```sh
sudo chown -R USER[:GROUP] /path/to/datadir 
sudo chmod -R 777 /path/to/datadir
```

## MySQL, TPC-C 실험
1. Install MySQL 5.7 and TPC-C  
Reference the [installation guide](https://github.com/meeeejin/SWE3033-F2021/blob/main/week-1/reference/tpcc-mysql-install-guide.md) to install and run TPC-C benchmark on MySQL 5.7

2. my.cnf 수정
```sh
#
# The MySQL database server configuration file
#
[client]
user    = root
port    = 3306
socket  = /tmp/mysql.sock

[mysql]
prompt  = \u:\d>\_

[mysqld_safe]
socket  = /tmp/mysql.sock

[mysqld]
# Basic settings
default-storage-engine = innodb
pid-file        = /path/to/datadir/mysql.pid
socket          = /tmp/mysql.sock
port            = 3306
datadir         = /path/to/datadir/
log-error       = /path/to/datadir/mysql_error.log

#
# Innodb settings
#
# Page size
innodb_page_size=16KB

# Buffer pool settings

##### Change buffer pool size according to data size(5GB, 10GB, 15GB)
innodb_buffer_pool_size=5G
innodb_buffer_pool_instances=8

# Transaction log settings
innodb_log_file_size=100M
innodb_log_files_in_group=2
innodb_log_buffer_size=32M

# Log group path (iblog0, iblog1)
# If you separate the log device, uncomment and correct the path
#innodb_log_group_home_dir=/path/to/logdir/

# Flush settings (SSD-optimized)
# 0: every 1 seconds, 1: fsync on commits, 2: writes on commits
innodb_flush_log_at_trx_commit=0
innodb_flush_neighbors=0
# innodb_flush_method=O_DIRECT

##### F2FS lfs mode O_DIRECT error
innodb_flush_method=fsync
```

3. 재실험 시 data directory 및 MySQL 초기화

```sh
//서버 종료
./bin/mysqladmin -uroot -p[yourPassword] shutdown

//SSD 초기화 및 File System Mount
...
...
//

./bin/mysqld --initialize --user=mysql --datadir=/path/to/datadir --basedir=/path/to/basedir

./bin/mysqld_safe --skip-grant-tables --datadir=/path/to/datadir

./bin/mysql -uroot

root:(none)> use mysql;

root:mysql> update user set authentication_string=password('yourPassword') where user='root';
root:mysql> flush privileges;
root:mysql> quit;

./bin/mysql -uroot -p[yourPassword]

root:mysql> set password = password('yourPassword');
root:mysql> quit;

./bin/mysqladmin -uroot -pyourPassword shutdown
./bin/mysqld_safe --defaults-file=/path/to/my.cnf

./bin/mysql -u root -p[yourPassword] -e "CREATE DATABASE tpcc;"
./bin/mysql -u root -p[yourPassword] tpcc < /home/vldb/MySQL/tpcc-mysql/create_table.sql
./bin/mysql -u root -p[yourPassword] tpcc < /home/vldb/MySQL/tpcc-mysql/add_fkey_idx.sql
```
4. TPC-C, 로그 쉘 시작
```sh
//다운로드 //두개 커맨드 중 택 1
//Warehouse Number: 500, 1000, 1500
./tpcc_load -h 127.0.0.1 -d tpcc -u root -p "yourPassword" -w [Warehouse Number]
./load.sh tpcc [Warehouse Number]


//다운로드 완료 후 // ps -ef | grep tpcc 로 다운로드 종료 여부 확인
./log_write.sh
./tpcc_start -h 127.0.0.1 -S /tmp/mysql.sock -d tpcc -u root -p "yourPassword" -w [Warehouse Number] -c 8 -r 10 -l [Run Time] | tee [Experiment Name].txt

```
## RocksDB, YCSB 실험
1. Install RocksDB  

- Upgrade gcc version at least 4.8
- gflags: `sudo apt-get install libgflags-dev`
  If this doesn't work, here's a nice tutorial:
  (http://askubuntu.com/questions/312173/installing-gflags-12-04)
- snappy: `sudo apt-get install libsnappy-dev`
- zlib: `sudo apt-get install zlib1g-dev`
- bzip2: `sudo apt-get install libbz2-dev

```sh
git clone https://github.com/facebook/rocksdb
cd rocksdb
make
make check
```
Reference: https://github.com/meeeejin/SWE3033-F2021/blob/main/week-6/README.md

2. Install YCSB

- Java:

```bash
$ sudo apt-get install openjdk-8-jdk
$ javac -version
javac 1.8.0_292
$ which javac
/usr/bin/javac
$ readlink -f /usr/bin/javac
/usr/lib/jvm/java-8-openjdk-amd64
$ sudo vi /etc/profile
...
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
$ source /etc/profile
$ echo $JAVA_HOME
/usr/lib/jvm/java-8-openjdk-amd64 
```

- Maven 3:

```bash
$ sudo apt-get install maven
```


1. Clone the [YCSB](https://github.com/brianfrankcooper/YCSB) git repository:

```bash
$ git clone https://github.com/brianfrankcooper/YCSB
```

2. Compile:

```bash
$ cd YCSB
$ mvn -pl site.ycsb:rocksdb-binding -am clean package
```
Reference: https://github.com/meeeejin/til/blob/master/benchmark/how-to-install-ycsb-for-rocksdb.md

3. Workload 수정
```sh
# Yahoo! Cloud System Benchmark
# Workload A: Update heavy workload
#   Application example: Session store recording recent actions
#
#   Read/update ratio: 50/50
#   Default data size: 1 KB records (10 fields, 100 bytes each, plus key)
#   Request distribution: zipfian

# 1G : 0 6개
# 40000000 --> 44GB
# 85000000 --> 93GB
# 125000000 --> 137GB
recordcount=40000000
operationcount=2000000000
workload=site.ycsb.workloads.CoreWorkload
maxexecutiontime=7200

readallfields=true

readproportion=0.5
updateproportion=0.5
scanproportion=0
insertproportion=0

requestdistribution=zipfian
```

4. YCSB 실행
```sh
//Data Download
./bin/ycsb load rocksdb -s -P workloads/[yourWorkload] -threads 8 -p rocksdb.dir=/path/to/datadir

//다운로드 
./log_write.sh
./bin/ycsb run rocksdb -s -P workloads/[yourWorkload] -threads 8 -p rocksdb.dir=/path/to/datadir 2>&1 | tee [Experiment Name].dat
```

## RocksDB-YCSB with Idle Time 실험  
RocksDB 및 YCSB을 SIGSTOP을 통해 일시 정지 시킴으로써 파일 시스템에 idle time을 제공하는 실험. 데이터 로드 후 rocks_idle.sh으로 실행 가능하다. 기본 10분 당 1분의 유휴 시간을 주도록 설정되어있으며, rocks_idle.sh의 수정을 통해 시간 수정이 가능하다. 또한, idle time의 OPS는 0으로 계산된다.
```sh
./rocks_idle.sh
```

## F2FS urgent 실험  
F2FS의 attribute 값을 바꿈으로써 파일 시스템 옵션 변경이 가능하다. F2FS의 attribute는 '/sys/fs/f2fs/[DEVICE]/'에서 변경 가능하며, 그에 대한 설명 문서는 https://elixir.bootlin.com/linux/v5.4/source/Documentation/filesystems/f2fs.txt 에서 확인 가능하다. 본 추가 실험에서는 gc_urgent 및 gc_urgent_sleep_time 인자를 변경함으로써 gc 및 discard 명령이 F2FS의 성능에 미치는 영향을 연구한다. 파일 시스템 마운트 후 해당 attribute 수정 후 벤치마크를 진행한다.  
* gc_urgent: Background GC를 즉시 할지 결정하는 인자. 기본으로 0(즉시 하지 않음)으로 설정되어있으며, 1로 변경 시 Background 쓰레드에서 gc_urgent_sleep_time 주기로 GC 명령을 수행한다.
* gc_urgent_sleep_time: gc_urgent 설정 시 gc의 주기를 결정한다. ms단위이며, 기본 500으로 설정되어 있다.  
```sh
sudo -E bash
echo 1 > /sys/fs/f2fs/sdb1/gc_urgent
echo 5000 > /sys/fs/f2fs/sdb1/gc_urgent_sleep_time    //5초(5000ms)로 설정
exit;
```


## 프로젝트 정보

학번 - 이름 - github주소 - 이메일

<!-- Markdown link & img dfn's -->
[npm-image]: https://img.shields.io/npm/v/datadog-metrics.svg?style=flat-square
[npm-url]: https://npmjs.org/package/datadog-metrics
[npm-downloads]: https://img.shields.io/npm/dm/datadog-metrics.svg?style=flat-square
[travis-image]: https://img.shields.io/travis/dbader/node-datadog-metrics/master.svg?style=flat-square
[travis-url]: https://travis-ci.org/dbader/node-datadog-metrics
[wiki]: https://github.com/yourname/yourproject/wiki
