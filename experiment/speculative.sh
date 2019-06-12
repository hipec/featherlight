#!/bin/bash

#---------------SET BY COMMAND LINE ARGS--------
TESTID=$1
THREADS=$2
LOGDIRNAME=$3
BENCHMARKID=$4
MAXINVOCATION=$5
TIMER=$6
#-----------HARD CODED--------------------------
#export JAVA_HOME=
MEM="3GB"
TIMEOUT=180
#-----------------------------------------------

##############################################################################
######################## NO MODIFICATIONS BELOW ##############################
##############################################################################

if [ $# -lt 4 ] 
then
	cat options-speculative.txt
	echo "USAGE: ./experiment.sh <TESTID> <THREADS> <LOGDIRNAME> <BENCHMARKID> <MAXINVOCATION> <[TIMEOUT]>"
	echo "--------------------------------------------------------------------"
	echo "--------------------------------------------------------------------"
	exit
fi
  
#Default timeout = 10 mins = 600 seconds
if [ $# -eq 6 ]
then
	TIMEOUT=$TIMER
fi

####################### SET BENCHMARK INPUT #################################
BENCHMARKARGS="" 
BENCHMARK=""
PREFIX=""
case $BENCHMARKID in
  "1" )
    BENCHMARK="UTS"
    PREFIX=$BENCHMARK ;;

  "4" )
    BENCHMARK="NQueens"
    PREFIX=$BENCHMARK ;;

  "5" )
    BENCHMARK="Sudoku"
    PREFIX=$BENCHMARK ;;

  "7" )
    BENCHMARK="ShortlongPath"
    PREFIX=$BENCHMARK ;;

  "8" )
    BENCHMARK="ArraySearch"
    PREFIX=$BENCHMARK ;;

  "9" )
    BENCHMARK="TSP"
    PREFIX=$BENCHMARK ;;

  "10" )
    BENCHMARK="lusearch-fix"
    PREFIX="DacapoLUSFix" ;;
esac
############################ COMMON VARIABLES ###############################
LOGDIR=$FEATHERLIGHT"/experiment/logs/"$LOGDIRNAME
JIKES_DIST=$JIKESRVM
JIKESRVM="$JIKESRVM/rvm"
##################### START THE EXPERIMENT ##################################

TMPFILE=`mktemp job.XXXXXXXX`
echo "#!/bin/bash" > $TMPFILE
chmod +x $TMPFILE

# VARIABLES TO BE SET INDIVIDUALLY
BENCHMARKDIR=""
CONFIG=""
RVMARGS="\" -Xws:procs="$THREADS" -Xws:autoThreads=true -Xws:pinAuto=true \""

# SEQUENTIAL JAVA EXPERIMENT
if [ $TESTID -eq 1 ]
then
	CONFIG="Sequential"
	THREADS=1
	if [ $PREFIX == "DacapoLUSFix" ]
        then
		RVMARGS="\" -Xws:pinAuto=true -jar dacapo-sequential.jar -c org.dacapo.harness.EuroPAR19 -n 1 \""
        	BENCHMARKDIR=$FEATHERLIGHT"/benchmarks/dacapo/benchmarks"
	else
		BENCHMARKDIR=$FEATHERLIGHT"/benchmarks/micro/$BENCHMARK/classes"
		RVMARGS="\" -Xws:pinAuto=true \""
		BENCHMARK="Sequential"
        fi
fi

# JAVATC SPECULATIVE TASK PARALLELISM EXPERIMENT (THREAD PINNING)
if [ $TESTID -eq 2 ]
then
	BENCHMARKDIR=$FEATHERLIGHT"/benchmarks/micro/$BENCHMARK/classes"
	if [ $PREFIX == "DacapoLUSFix" ]
        then
		RVMARGS="\" -Xws:procs="$THREADS" -Xws:autoThreads=true -Xws:pinAuto=true -jar dacapo-featherlight.jar -c org.dacapo.harness.EuroPAR19 -n 1 \""
        	BENCHMARKDIR=$FEATHERLIGHT"/benchmarks/dacapo/benchmarks"
	else
		BENCHMARK="Featherlight"
        fi
	CONFIG="Featherlight"
fi

# JAVATC ASYNC FINISH MANUAL ABORT EXPERIMENT (THREAD PINNING)
if [ $TESTID -eq 4 ]
then
	BENCHMARKDIR=$FEATHERLIGHT"/benchmarks/micro/$BENCHMARK/classes"
	if [ $PREFIX == "DacapoLUSFix" ]
        then
		RVMARGS="\" -Xws:procs="$THREADS" -Xws:autoThreads=true -Xws:pinAuto=true -jar dacapo-manualabort.jar -c org.dacapo.harness.EuroPAR19 -n 1 \""
        	BENCHMARKDIR=$FEATHERLIGHT"/benchmarks/dacapo/benchmarks"
	else
		BENCHMARK="ManualAbort"
        fi
	CONFIG="ManualAbort"
fi

# FORKJOINPOOL ABORT EXPERIMENT (THREAD PINNING)
if [ $TESTID -eq 5 ]
then
	CONFIG="ForkJoin"
	if [ $PREFIX == "DacapoLUSFix" ]
        then
        	BENCHMARKDIR=$FEATHERLIGHT"/benchmarks/dacapo/benchmarks"
		BENCHMARKARGS="\" -t "$THREADS" \""
		RVMARGS="\" -Xws:pinAuto=true -X:vmClasses="$JIKES_DIST"/jksvm.jar:"$JIKES_DIST"/rvmrt.jar:"$FEATHERLIGHT"/benchmarks/micro/jsr166y.jar -jar dacapo-forkjoin.jar -c org.dacapo.harness.EuroPAR19 -n 1 \""
        else
		BENCHMARKDIR=$FEATHERLIGHT"/benchmarks/micro/$BENCHMARK/classes"
		BENCHMARK="ForkJoin"
		RVMARGS="\" -Xws:pinAuto=true -cp ../../jsr166y.jar:. \""
		BENCHMARKARGS="\" "$THREADS" \""
	fi
fi

########################### RUN CONFIG ##########################################

echo "RVMARGS=\\\""$RVMARGS"\\\"" >> $TMPFILE
echo "BENCHMARK=\""$BENCHMARK"\"" >> $TMPFILE
echo "PREFIX=\""$PREFIX"\"" >> $TMPFILE
echo "BENCHMARKARGS=\\\""$BENCHMARKARGS"\\\"" >> $TMPFILE
echo "LOGDIR=\""$LOGDIR"\"" >> $TMPFILE
echo "BENCHMARKDIR=\""$BENCHMARKDIR"\"" >> $TMPFILE
echo "TIMEOUT=\""$TIMEOUT"\"" >> $TMPFILE
echo "MAXINVOCATION=\""$MAXINVOCATION"\"" >> $TMPFILE
echo "THREADS=\""$THREADS"\"" >> $TMPFILE
echo "CONFIG=\""$CONFIG"\"" >> $TMPFILE
echo "JIKESRVM=\""$JIKESRVM"\"" >>$TMPFILE
echo "TMPFILE=\""$TMPFILE"\"" >>$TMPFILE
echo "PARAMS=(\$BENCHMARK \$BENCHMARKARGS \$LOGDIR \$BENCHMARKDIR \$TIMEOUT \$THREADS \$CONFIG \$JIKESRVM \$TMPFILE \$MAXINVOCATION \$PREFIX \$RVMARGS)" >> $TMPFILE
echo "eval perl launcher \"\${PARAMS[@]}\"" >> $TMPFILE

./$TMPFILE
echo "DONE...."
rm ./$TMPFILE

