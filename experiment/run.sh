#! /bin/bash 

#Change the below array if you want to run with different values of thread count
THREADS=( 8 12 16 20 )

#Don't add seuential experiment here as its carried out by default below
EXPERIMENTS=( 2 4 5 )

#All the benchmarks will be run by this script
BENCHMARKS=( 1 4 5 7 8 9 10 )

#Smaller number of INVOCATIONS will complete the run sooner. Large number of 
#INVOCATIONS will help in getting better average execution time
INVOCATIONS=7

#This variable only control the total invocations
#for Sequential execution of each benchmarks. Note
#that Sequential versions are the most time consuming
#ones but have least variations in execution time 
#across different invocations. Hence, you can safely
#lower this counter to save time. Also changing this
#counter here has no effect in other scripts.
SEQUENTIAL_INVOCATION=4

#If you change the name of output directory then change accordingly in 
#other two speedup calculation scripts as well
LOG_DIR_NAME="paper75"

##########################################
####### DONT CHANGE ANYTHING BELOW #######
##########################################

GLOBAL=$SECONDS
for benchmark in "${BENCHMARKS[@]}"; do
  #single profile run 
  START=$SECONDS
  ./speculative.sh 1 1 del $benchmark 1 10000
  DURATION=$(( SECONDS - START ))
  MAX_TIMEOUT=`printf "%.0f" $(echo "$DURATION * 3" | bc)`
  #Sequential run
  ./speculative.sh 1 1 $LOG_DIR_NAME $benchmark $SEQUENTIAL_INVOCATION $MAX_TIMEOUT
  #Parallel runs
  BENCH_NAME=""
  case $benchmark in
    "1" )
    BENCH_NAME="UTS" ;;
    "4" )
    BENCH_NAME="NQueens" ;;
    "5" )
    BENCH_NAME="Sudoku" ;;
    "7" )
    BENCH_NAME="ShortlongPath" ;;
    "8" )
    BENCH_NAME="ArraySearch" ;;
    "9" )
    BENCH_NAME="TSP" ;;
    "10" )
    BENCH_NAME="DacapoLUSFix" ;;
  esac
  for thread in "${THREADS[@]}"; do
    for experiment in "${EXPERIMENTS[@]}"; do
      PREFIX=""
      case $experiment in
        "2" )
        PREFIX="Featherlight" ;;
        "4" )
        PREFIX="ManualAbort" ;;
        "5" )
        PREFIX="ForkJoin" ;;
      esac
      success=0
      echo "Running: "$BENCH_NAME.3096.1024.$PREFIX.threads-$thread.log
      while [ 1 ]
      do
        ./speculative.sh $experiment $thread $LOG_DIR_NAME $benchmark $INVOCATIONS $MAX_TIMEOUT
        if [ ! -e logs/$LOG_DIR_NAME/$BENCH_NAME.3096.1024.$PREFIX.threads-$thread.log.gz ]
        then
          echo "File logs/$LOG_DIR_NAME/$BENCH_NAME.3096.1024.$PREFIX.threads-$thread.log.gz Does Not Exists"
          if [ -e logs/$LOG_DIR_NAME/$BENCH_NAME.3096.1024.$PREFIX.threads-$thread.log ]
          then
            ITERS=`cat logs/$LOG_DIR_NAME/$BENCH_NAME.3096.1024.$PREFIX.threads-$thread.log | grep "TEST PASSED" | wc -l`
            if [ $ITERS -gt 0 ]
            then
              cat logs/$LOG_DIR_NAME/$BENCH_NAME.3096.1024.$PREFIX.threads-$thread.log >> logs/$LOG_DIR_NAME/$BENCH_NAME.3096.1024.$PREFIX.threads-$thread.log_total
              success=`expr $success + $ITERS`
              if [ $success -ge $INVOCATIONS ]
              then
                mv logs/$LOG_DIR_NAME/$BENCH_NAME.3096.1024.$PREFIX.threads-$thread.log_total logs/$LOG_DIR_NAME/$BENCH_NAME.3096.1024.$PREFIX.threads-$thread.log
                gzip logs/$LOG_DIR_NAME/$BENCH_NAME.3096.1024.$PREFIX.threads-$thread.log
                break
              fi
            fi
          fi
        else
          break
        fi
      done
    done
  done
done
rm logs/$LOG_DIR_NAME/*.log_total
echo "TOTAL TIME TO RUN WAS "$(( SECONDS - GLOBAL ))
