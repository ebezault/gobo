#!/bin/sh

mkdir precomp
cd precomp
cp $GOBO/test/precomp/se.sh .
./se.sh > tmp11.txt 2>&1

if [ -s tmp11.txt ]; then
	cat tmp11.txt
	echo "Test FAILED"
else
	echo "Test SUCCESSFUL"
fi
