#!/bin/bash

export FEATHERLIGHT=/mnt/hdd2/home/vivekk/featherlight
export JAVA_HOME=<absolute path to jdk1.6.0_31>

############ DON't CHANGE ANYTHING BELOW ##########

export PATH=$JAVA_HOME/bin:$PATH
export JIKESRVM=${FEATHERLIGHT}/JikesRVM/dist/production_x86_64-linux
export AJWS=${FEATHERLIGHT}/ajws/src
export TRANSLATOR=/${FEATHERLIGHT}/translator/transform.sh
