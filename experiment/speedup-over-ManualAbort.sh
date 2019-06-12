#! /bin/bash 

#Change the below array with maximum thread 
#count as specified in run.sh script
THREADS=( 20 )

BENCHMARKS=( "UTS" "NQueens" "Sudoku" "ShortlongPath" "ArraySearch" "TSP" "DacapoLUSFix" )

#If you changed the name of output directory in run.sh
#then change accordingly in both speedup calculation 
#scripts (including this)
LOG_DIR_NAME="paper75"

##########################################
####### DONT CHANGE ANYTHING BELOW #######
##########################################

gunzip logs/$LOG_DIR_NAME/*.gz

for thread in "${THREADS[@]}"; do
echo "====== Speedup of Featherlight over ManualAbort At Max Thread (=$thread) ======"
for benchmark in "${BENCHMARKS[@]}"; do
  featherlight=0
  manual=0
  invocations=0
  #Featherlight
  if [ `grep "Total time:" logs/$LOG_DIR_NAME/$benchmark.3096.1024.Featherlight.threads-$thread.log | wc -l` -gt 0 ]; then
    for i in `grep "Total time:" logs/$LOG_DIR_NAME/$benchmark.3096.1024.Featherlight.threads-$thread.log | awk '{print $3}'`; do
      featherlight=`echo $featherlight + $i | bc -l`
      invocations=`expr $invocations + 1`
    done
    featherlight=`echo $featherlight / $invocations | bc -l`
    invocations=0
  fi

  #ManualAbort
  if [ `grep "Total time:" logs/$LOG_DIR_NAME/$benchmark.3096.1024.ManualAbort.threads-$thread.log | wc -l` -gt 0 ]; then
    for i in `grep "Total time:" logs/$LOG_DIR_NAME/$benchmark.3096.1024.ManualAbort.threads-$thread.log | awk '{print $3}'`; do
      manual=`echo $manual + $i | bc -l`
      invocations=`expr $invocations + 1`
    done
    manual=`echo $manual / $invocations | bc -l`
    invocations=0
  fi
  speedup=0
  if [ `printf "%.0f" $featherlight` -gt 0 ]; then
    speedup=`echo $manual / $featherlight | bc -l`
  fi
  printf "%s    %.2f\n" $benchmark $speedup
done
done

