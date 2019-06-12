#! /bin/bash 

#Change the below array with thread 
#counts as specified in run.sh script
THREADS=( 1 4 8 12 16 20 )

BENCHMARKS=( "UTS" "NQueens" "Sudoku" "ShortlongPath" "ArraySearch" "TSP" "DacapoLUSFix" )

#If you changed the name of output directory in run.sh
#then change accordingly in both speedup calculation 
#scripts (including this)
LOG_DIR_NAME="paper75"

##########################################
####### DONT CHANGE ANYTHING BELOW #######
##########################################

gunzip logs/$LOG_DIR_NAME/*.gz

for benchmark in "${BENCHMARKS[@]}"; do
  # First calculate average sequential time
  seqTime=0
  invocations=0
  for i in `grep "Total time:" logs/$LOG_DIR_NAME/$benchmark.3096.1024.Sequential.threads-1.log | awk '{print $3}'`; do
    seqTime=`echo $seqTime + $i | bc -l`
    invocations=`expr $invocations + 1`
  done
  seqTime=`echo $seqTime / $invocations | bc -l`
  echo "====== $benchmark Speedup over Sequential ======"
  echo "THREADS    Featherlight    ForkJoin"
  for thread in "${THREADS[@]}"; do
    featherlight=0
    forkjoin=0
    invocations=0
    #Featherlight
    if [ `grep "Total time:" logs/$LOG_DIR_NAME/$benchmark.3096.1024.Featherlight.threads-$thread.log | wc -l` -gt 0 ]; then
      for i in `grep "Total time:" logs/$LOG_DIR_NAME/$benchmark.3096.1024.Featherlight.threads-$thread.log | awk '{print $3}'`; do
        featherlight=`echo $featherlight + $i | bc -l`
        invocations=`expr $invocations + 1`
      done
      featherlight=`echo $featherlight / $invocations | bc -l`
      featherlight=`echo $seqTime / $featherlight | bc -l`
      invocations=0
    fi

    #ForkJoin
    if [ `grep "Total time:" logs/$LOG_DIR_NAME/$benchmark.3096.1024.ForkJoin.threads-$thread.log | wc -l` -gt 0 ]; then
      for i in `grep "Total time:" logs/$LOG_DIR_NAME/$benchmark.3096.1024.ForkJoin.threads-$thread.log | awk '{print $3}'`; do
        forkjoin=`echo $forkjoin + $i | bc -l`
        invocations=`expr $invocations + 1`
      done
      forkjoin=`echo $forkjoin / $invocations | bc -l`
      forkjoin=`echo $seqTime / $forkjoin | bc -l`
      invocations=0
    fi
    printf "%d    %.2f    %.2f\n" $thread    $featherlight    $forkjoin
  done
done

