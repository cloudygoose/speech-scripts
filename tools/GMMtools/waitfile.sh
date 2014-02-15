#!/bin/bash
if [ $# -lt 1 ]; then
    echo "Usage waitfile filename [command]"
    exit 1;
fi
echo waiting for $1...
while true
do
    if [ -f $1 ]; then
        echo "found"
        break
    fi
    sleep 5
    if [ $# -eq 2 ]; then
        eval $2
    fi
done
