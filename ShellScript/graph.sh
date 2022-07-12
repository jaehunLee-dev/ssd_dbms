#!/bin/sh
  gnuplot << EOF
set te jpeg giant size 600,600 font "Arial San serif 10;
set style data lines;
set xlabel "Time(second)";
set ylabel "OPS(K)" font ", 15";

set key inside center top font ", 13";
set xrange [0:2640];
set yrange [0:80];

#set title "OPS(Disk Util 20%)" font ":Bold,15";
set output "disk20ops_1.jpeg";
plot "< cat $1" u 1:2 ls 2 lt 2 linecolor "orange-red" lw 3 ti "Ext4", "< cat $2" u 1:2 ls 2 lt 2 linecolor "skyblue" lw 3 ti "F2FS" ,"< cat $3" u 1:2 ls 2 lt 2 linecolor "web-green" lw 3 ti "XFS";

EOF
