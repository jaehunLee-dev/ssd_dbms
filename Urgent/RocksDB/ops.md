# RocksDB - YCSB OPS

| disk util | F2FS(Urgent,SSR) | F2FS(Urgent,LFS) | F2FS(No urgent) | Ext4            | XFS             |
|-----------|------------------|------------------|-----------------|-----------------|-----------------|
| 20%       | 52503            | 53686            | 27400           | 52400           | 46000           |
| 60%       | 32712            | 34552            | 17500           | 29900           | 28200           |

* Urgent 옵션 적용 시 기존에 하지 않던 SSR 기능을 수행하는 것 확인
