#!/bin/bash

password="vldb1234"
    
RESULT_PATH=/home/vldb/RocksDB/result
TEST_NAME="ext4_44_0621"
DEV="/dev/sdb1"

log_streams(){
	while true
	do
		echo $password | sudo -S smartctl -A ${DEV}
		sleep 60
	done
}
dirty_streams() {
	while true
	do
		df -h ${DEV}
		sleep 1
	done
}

logwaf_streams(){
        while true
        do
                cat /proc/fs/f2fs/sdb1/iostat_info
                sleep 1
        done
}

logwaf__streams(){
	while true
	do
		echo $password | sudo -S cat /sys/kernel/debug/f2fs/status
		sleep 5
	done
}

#iostat
echo "iostat starting"
echo $password | sudo -S iostat -xm 1 ${DEV} > ${RESULT_PATH}/iostat/${TEST_NAME}.iostat &
echo "iostat started"

#blktrace
echo "blktrace starting"
echo $password | sudo -S blktrace ${DEV} -o result/blktrace/${TEST_NAME} -a issue -a requeue -a complete &
echo "blktrace started"

(dirty_streams >> ${RESULT_PATH}/log/df/${TEST_NAME}_df.log) &
dirty_pid=$!

(log_streams >> ${RESULT_PATH}/log/smartctl/${TEST_NAME}_smartctl.log) &
stream_pid=$!

#(logwaf_streams >> ${RESULT_PATH}/log/logWaf/${TEST_NAME}_logwaf.log) &
#logwaf_pid=$!

#(logwaf__streams >> ${RESULT_PATH}/log/logWaf/${TEST_NAME}__logwaf.log) &
#logwaf__pid=$!

sleep 7200 #실험 시간만큼 sleep
echo $password | sudo -S kill -9 ${dirty_pid}
echo $password | sudo -S kill -9 ${stream_pid}
#echo $password | sudo -S kill -9 ${logwaf_pid}
#echo $password | sudo -S kill -9 ${logwaf__pid}
echo $password | sudo -S killall -15 iostat
echo $password | sudo -S killall -15 blktrace
echo $password | sudo -S blkparse result/blktrace/${TEST_NAME} > ./result/blktrace/${TEST_NAME}.btrace #blktrace parsing

echo $password | sudo -S cat ${RESULT_PATH}/iostat/*.iostat| grep sdb1 | awk '{print $5}' | grep -o '[0-9.]*' > ${RESULT_PATH}/iostat/${TEST_NAME}.BW
