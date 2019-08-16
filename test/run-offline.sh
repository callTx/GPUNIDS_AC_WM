#!/bin/bash

DIR=`date +%Y-%m-%d:%H:%M`
mkdir "$DIR"

echo "Data,CPU(%),Mem(%),Tempo" > $DIR/CPU_resources.csv
echo "Starting GPUNIDS"
echo "Running in: CPU"
../build/./GPUNIDS -o 10s-iperf.pcap -r rules.csv -f "tcp port 5201 and ip src 10.0.0.1" -p S -l 10 > $DIR/output.txt & pid=$!
while [ -e /proc/$pid ]
do
    ram=`ps -p $pid -o %mem | tail -1 | cut -f2 -d " "`
    cpu=`ps -p $pid -o %cpu | tail -1 | cut -f2 -d " "`
    elapsed_time=`ps -o etime= -p $pid`
    echo `date +%Y-%m-%d:%H:%M:%S`","$cpu","$ram","$elapsed_time >> $DIR/CPU_resources.csv
    sleep 1s
done

echo "Starting GPUNIDS"
echo "Running in: GPU"
for buffer in 262144 524288 1048576 2097152 4194304 8388608 16777216 33554432 67108864
do
      echo "	Buffer: $buffer B"
      ../build/./GPUNIDS -o 10s-iperf.pcap -r rules.csv -b $buffer -f "tcp port 5201 and ip src 10.0.0.1" -p P -l 10 >> $DIR/output.txt & pid=$!
      echo "Data,CPU(%),Mem(%),Tempo,GPU(%),GPU_Mem,GPU_Pwr,GPU_tmp(deg)" > $DIR/GPU_${buffer}_resources.csv
      while [ -e /proc/$pid ]
      do
          ram=`ps -p $pid -o %mem | tail -1 | cut -f2 -d " "`
          cpu=`ps -p $pid -o %cpu | tail -1 | cut -f2 -d " "`
          elapsed_time=`ps -o etime= -p $pid`
          echo -n `date +%Y-%m-%d:%H:%M:%S`","$cpu","$ram","$elapsed_time"," >> $DIR/GPU_${buffer}_resources.csv
          nvidia-smi --query-gpu=utilization.gpu,memory.used,power.draw,temperature.gpu  --format=csv | tail -1 >> $DIR/GPU_${buffer}_resources.csv
          sleep 1s
      done
done

echo "Done"
