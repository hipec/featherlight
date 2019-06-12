#!/bin/bash

cd $FEATHERLIGHT
git clone https://github.com/JikesRVM/JikesRVM.git
cd JikesRVM
git checkout 087d300
patch -p1 <../patches/jikesrvm.patch
/bin/bash --login -c  '/bin/bash --login -c  "   cd $PWD &&  export JAVA_HOME=$PWD/../jdk1.6.0_31 &&   ant very-clean -Dhost.name=x86_64-linux &&  ant check-components-properties -Dhost.name=x86_64-linux -Dtarget.name=x86_64-linux -Dcomponents.cache.dir=$FEATHERLIGHT/jikesrvm_components_cache  &&   ant -Dtarget.name=x86_64-linux -Dconfig.name=production -Dgit.revision=1c49b135cb94e80bb0f81b3251fef62311fe1f3f -Dhost.name=x86_64-linux -Dcomponents.cache.dir=$FEATHERLIGHT/jikesrvm_components_cache "' 

