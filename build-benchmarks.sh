#!/bin/bash

cd $FEATHERLIGHT/benchmarks/micro
make

cd $FEATHERLIGHT/benchmarks/dacapo/benchmarks/bms/Featherlight
make
cd $FEATHERLIGHT/benchmarks/dacapo/benchmarks
mv dacapo.jar dacapo-featherlight.jar

cd $FEATHERLIGHT/benchmarks/dacapo/benchmarks/bms/ManualAbort
make
cd $FEATHERLIGHT/benchmarks/dacapo/benchmarks
mv dacapo.jar dacapo-manualabort.jar

cd $FEATHERLIGHT/benchmarks/dacapo/benchmarks/bms/Sequential
make
cd $FEATHERLIGHT/benchmarks/dacapo/benchmarks
mv dacapo.jar dacapo-sequential.jar

cd $FEATHERLIGHT/benchmarks/dacapo/benchmarks/bms/ForkJoin
make
cd $FEATHERLIGHT/benchmarks/dacapo/benchmarks
mv dacapo.jar dacapo-forkjoin.jar
