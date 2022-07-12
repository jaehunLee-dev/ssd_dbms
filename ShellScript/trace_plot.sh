#!/bin/sh

files=$@

if [ ! -d plot ] 
then
    mkdir -p plot
fi

for file in $files
do
   plotfile=${file}_gnuplot
   cat ${file} | awk '{printf "%s,%d,%d,%.3f,%d\n",$7, $8, $10, $4, NR}' > ${plotfile};

   gnuplot << EOF

set te jpeg giant size 1200,600 font "Arial San serif 10;

set xlabel "Timestamp (second)";

set ylabel "Logical Sector Number";
set pointsize 0.2;
set key inside left top;
set datafile separator ",";
set xrange [0:7200];
set yrange [0:500000000];	#blktrace에서 sector number 확인 후 변경하기
set output "${file}.jpeg";

plot "< grep R ${plotfile}" u 4:2 ti "Read", "< grep W ${plotfile}" u 4:2 ti "Write";

set output "${file}_read.jpeg";

plot "< grep R ${plotfile}" u 4:2 ls 1 ti "Read";

set output "${file}_write.jpeg";

plot "< grep W ${plotfile}" u 4:2 ls 2 ti "Write";


EOF
mv /home/vldb/RocksDB/result/blktrace/*.jpeg plot;
rm -f ${plotfile}

done




