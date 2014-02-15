#/bin/bash
if [ $# -ne 1 ]; then
    echo " Usage : ./waitforjob.sh jobid "
fi
echo "waiting for job $1..."
mkdir -p tmp
echo "echo LOVE" > tmp/no-use.sh
qsub -cwd -o LOG -e LOG -hold_jid $1 -sync y tmp/no-use.sh
rm tmp/no-use.sh

