#!/bin/bash

echo "Starting ITGRecv..."
/home/igor/pcap_test/D-ITG/D-ITG-2.8.1-r1023/bin/./ITGRecv & pidITG=$!

echo "Data,CPU(%),Mem(%),Tempo" > CPU_resources.csv
echo "Starting AhoCorasickGPU"
echo "Running in: CPU"
build/./AhoCorasickGPU teste.pcap S > CPU_log.txt & pid=$!
echo "Starting ITGSend..."
ssh igor@10.0.0.1 'D-ITG/D-ITG-2.8.1-r1023/bin/./ITGSend -T TCP -a 10.0.0.2 -e 512 -U 234902 288325 -t 3600000 -l CPU_sender.log -x CPU_receiver.log' &
while [ -e /proc/$pid ]
do
    ram=`ps -p $pid -o %mem | tail -1 | cut -f2 -d " "`
    cpu=`ps -p $pid -o %cpu | tail -1 | cut -f2 -d " "`
    elapsed_time=`ps -o etime= -p $pid`
    echo `date +%Y-%m-%d:%H:%M:%S`","$cpu","$ram","$elapsed_time >> CPU_resources.csv
    sleep 1s
done

echo "Starting AhoCorasickGPU"
echo "Running in: GPU"
for buffer in 8196 4096 2048 1024 512 256
do
      echo "	Buffer: $buffer B"
      build/./AhoCorasickGPU teste.pcap P $buffer  > GPU_${buffer}_log.txt & pid=$!
      echo "Starting ITGSend..."
      ssh igor@10.0.0.1 'D-ITG/D-ITG-2.8.1-r1023/bin/./ITGSend -T TCP -a 10.0.0.2 -e 512 -U 234902 288325 -t 3600000 -l GPU_sender.log -x GPU_receiver.log' &
      echo "Data,CPU(%),Mem(%),Tempo,GPU(%),GPU_Mem,GPU_Pwr,GPU_tmp(º)" > GPU_${buffer}_resources.csv
      while [ -e /proc/$pid ]
      do
          ram=`ps -p $pid -o %mem | tail -1 | cut -f2 -d " "`
          cpu=`ps -p $pid -o %cpu | tail -1 | cut -f2 -d " "`
          elapsed_time=`ps -o etime= -p $pid`
          echo -n `date +%Y-%m-%d:%H:%M:%S`","$cpu","$ram","$elapsed_time"," >> GPU_${buffer}_resources.csv
          nvidia-smi --query-gpu=utilization.gpu,memory.used,power.draw,temperature.gpu  --format=csv | tail -1 >> GPU_${buffer}_resources.csv
          sleep 1s
      done
done

echo "Killing ITGRecv..."
kill $pidITG
echo "Done"
