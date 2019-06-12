#!/bin/bash

cd $FEATHERLIGHT
git clone https://github.com/vivkumar/ajws.git
cd ajws
git checkout bd5535f
patch -p1 <../patches/ajws.patch
cd src
ant clean
ant jar
