#!/bin/bash
for (( counter=0; counter<100000; counter++ ))
do
dd if=/dev/zero of=$counter bs=1M count=10
done


