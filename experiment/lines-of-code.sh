#! /bin/bash 

BENCHMARKS=( 1 4 5 7 8 9 10 )
####### DONT CHANGE ANYTHING BELOW #######

echo "Benchmark    Common_Code    Sequential    Featherlight    ManualAbort    ForkJoin"
for benchmark in "${BENCHMARKS[@]}"; do
  BENCH_NAME=""
  LOCATION="$FEATHERLIGHT/benchmarks/micro"
  MICRO=0
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
    MICRO=1
    LOCATION="$FEATHERLIGHT/benchmarks/dacapo/benchmarks/bms"
    BENCH_NAME="DacapoLUSFix" ;;
  esac

  sequential=""
  config=""
  featherlight=""
  manualabort=""
  forkjoin=""
  cd $LOCATION
  if [ $MICRO -eq 0 ]; then
    sequential=`sloccount $LOCATION/$BENCH_NAME/Sequential.java | grep "Source Lines of Code" | awk '{print $9}'`
    config=`sloccount $LOCATION/$BENCH_NAME/Config.java | grep "Source Lines of Code" | awk '{print $9}'`
    featherlight=`sloccount $LOCATION/$BENCH_NAME/Featherlight.java | grep "Source Lines of Code" | awk '{print $9}'`
    manualabort=`sloccount $LOCATION/$BENCH_NAME/ManualAbort.java | grep "Source Lines of Code" | awk '{print $9}'`
    forkjoin=`sloccount $LOCATION/$BENCH_NAME/ForkJoin.java | grep "Source Lines of Code" | awk '{print $9}'`
  else
    sequential=`sloccount $LOCATION/Sequential/Search.java | grep "Source Lines of Code" | awk '{print $9}'` 
    sloccount $LOCATION/../ &> __out
    config=`cat __out |  grep "Total Physical Source Lines of Code" | awk '{print $9}'`
    rm __out
    featherlight=`sloccount $LOCATION/Featherlight/Search.java | grep "Source Lines of Code" | awk '{print $9}'` 
    manualabort=`sloccount $LOCATION/ManualAbort/Search.java | grep "Source Lines of Code" | awk '{print $9}'` 
    forkjoin=`sloccount $LOCATION/ForkJoin/Search.java | grep "Source Lines of Code" | awk '{print $9}'` 
  fi
  echo "$BENCH_NAME    $config    $sequential    $featherlight    $manualabort    $forkjoin" 
done
