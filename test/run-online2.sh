#!/bin/bash

DIR=`date +%Y-%m-%d:%H:%M`
mkdir "$DIR"

echo "Starting Iperf Server..."
iperf3 -s > $DIR/iperf.log & pidIperf=$!

echo "$DIR" > $DIR/output.txt
echo "$DIR" > $DIR/resources.csv

for througput in 1mb 10mb 50mb 100mb 200mb 400mb 800mb
do

echo "Starting GPUNIDS"
echo "Running in: GPU"
for buffer in 262144 524288 1048576 2097152 4194304 8388608 16777216 33554432
do
      echo "	Buffer: $buffer B"
      echo "Througput : $througput" >> $DIR/output.txt
      ../build/./GPUNIDS -i p2p1 -r rules.csv -b $buffer -f "tcp port 5201 and ip src 10.0.0.1" -p P -l 10 -t 4 >> $DIR/output.txt & pid=$!
      echo "GPU $througput $buffer" >> $DIR/resources.csv
      echo "Data,CPU(%),Mem(%),Tempo,GPU(%),GPU_Mem,GPU_Pwr,GPU_tmp(deg)" >> $DIR/resources.csv

      ssh igor@10.0.0.1 "iperf3 -c 10.0.0.2 -b $througput -t 3600 > iperf.log" &
      while [ -e /proc/$pid ]
      do
          ram=`ps -p $pid -o %mem | tail -1 | cut -f2 -d " "`
          cpu=`ps -p $pid -o %cpu | tail -1 | cut -f2 -d " "`
          elapsed_time=`ps -o etime= -p $pid`
          echo -n `date +%Y-%m-%d:%H:%M:%S`","$cpu","$ram","$elapsed_time"," >> $DIR/resources.csv
          nvidia-smi --query-gpu=utilization.gpu,memory.used,power.draw,temperature.gpu  --format=csv | tail -1 >> $DIR/resources.csv
          sleep 1s
      done
done
done

echo "Starting GPUNIDS"
echo "Running in: GPU"
for buffer in 262144 524288 1048576 2097152 4194304 8388608 16777216 33554432
do
      echo "	Buffer: $buffer B"
      echo "Througput : 1gb" >> $DIR/output.txt
      ../build/./GPUNIDS -i p2p1 -r rules.csv -b $buffer -f "tcp port 5201 and ip src 10.0.0.1" -p P -l 10 -t 4 >> $DIR/output.txt & pid=$!
      echo "GPU 1gb $buffer" >> $DIR/resources.csv
      echo "Data,CPU(%),Mem(%),Tempo,GPU(%),GPU_Mem,GPU_Pwr,GPU_tmp(deg)" >> $DIR/resources.csv

      ssh igor@10.0.0.1 "iperf3 -c 10.0.0.2 -t 3600 > iperf.log" &
      while [ -e /proc/$pid ]
      do
          ram=`ps -p $pid -o %mem | tail -1 | cut -f2 -d " "`
          cpu=`ps -p $pid -o %cpu | tail -1 | cut -f2 -d " "`
          elapsed_time=`ps -o etime= -p $pid`
          echo -n `date +%Y-%m-%d:%H:%M:%S`","$cpu","$ram","$elapsed_time"," >> $DIR/resources.csv
          nvidia-smi --query-gpu=utilization.gpu,memory.used,power.draw,temperature.gpu  --format=csv | tail -1 >> $DIR/resources.csv
          sleep 1s
      done
done
echo "Killing iperf3 Server"
kill $pidIperf
echo "Done"
