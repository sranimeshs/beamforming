#!/bin/bash

for f in $1/*.wav
do
	if [[ $f == *false* ]];
	then
		echo "`realpath $f`,False,M" >> $2
	else
		echo "`realpath $f`,True,M" >> $2
	fi

done
