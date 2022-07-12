password="vldb1234"

#./bin/ycsb run rocksdb -s -P workloads/myworkloada -threads 8 -p rocksdb.dir=/home/vldb/RocksDB/data & 2>&1 | tee f2fs_idle_60.dat
./rocks_strt.sh &
#p_pid=$!
#echo "ppid::	"${p_pid}
sleep 10
idle_pid=`ps -ef | grep YCSB | head -n 1 |awk '{print $2}'`
#echo "pid::   "${idle_pid}
check=0
while true
do
	#check=`ps -ef | grep '${idle_pid}' | wc | awk '{print $1}'`
	#echo ${check}
	#if [[ $check -le 1 ]]
	#then
	#	break
	#fi
	if [[ $check -eq 6 ]]#7200 sec 11
	then
		break
	fi
	sleep 600
	echo $password | sudo -S kill -19 ${idle_pid}
	sleep 60
	echo $password | sudo -S kill -18 ${idle_pid}
	check=$((check+1))
done
