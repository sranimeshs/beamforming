#!/bin/bash

mkdir -p temp

cd $1
for f in *.wav
do
	sox $f -r 16000 ../temp/$f
done
cd ..

cd false_combined/
for f in *.wav
do
	sox $f -r 16000 ../temp/$f
done
cd ..

mv temp ./$2
