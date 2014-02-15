#!/bin/bash
if [ $# -ne 2 ]; then
    echo usage : splitscp.sh splitNumber .scp
    exit 1
fi
EXT=${2##*.}
echo $EXT
if [ ! $EXT == "scp" ]; then
    echo '$2 must be a .scp file'
    exit 1
fi
NUM=$1
DIR=$(dirname $2)
NAME=$(basename $2) && NAME=${NAME%.*}
SCPFILE=$2
SIDELIST=$DIR"/"$NAME".sidelist"
rm $SIDELIST
for i in $(seq $NUM)
do
    echo writing to $DIR"/"$NAME"_"$i".scp"
    rm $DIR"/"$NAME"_"$i".scp"
    echo $NAME"_"$i >> $SIDELIST
done
cat $SCPFILE | awk -v dir=$DIR -v name=$NAME -v num=$NUM ' { print $0 > dir"/"name"_"(NR % num + 1)".scp" } '
