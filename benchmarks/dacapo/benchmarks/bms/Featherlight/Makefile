all:
	EXTRA_JARS_AJWS="./lucene-core-2.4.jar" $(TRANSLATOR) Search.java
	cp classes/Search.java ../lusearch-fix/src/org/dacapo/lusearchFix/Search.java
	cp ./bms-lusearch-fix-build.xml  ../lusearch-fix/build.xml
	cp ./libs.xml ../../libs/.
	cp QueryParserTokenManager.java ../../libs/lucene/downloads/lucene-2.4.1/src/java/org/apache/lucene/queryParser/.
	cp lucene-build.xml  ../../libs/lucene/downloads/lucene-2.4.1/build.xml
	rm ../../libs/lucene/downloads/lucene-2.4.1-src.tar.gz 2>/dev/null
	cp -rf ../../libs/lucene/downloads/lucene-2.4.1 .
	tar cvfz lucene-2.4.1-src.tar.gz lucene-2.4.1
	rm -rf lucene-2.4.1
	mv lucene-2.4.1-src.tar.gz ../../libs/lucene/downloads/.
	cd ../../; ant clean lusearch-fix
clean:
	rm -rf classes logs 2>/dev/null
