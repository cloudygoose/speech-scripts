#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 HTE"
    exit
fi

source $1

########################################################

##############################
#check for obligatory parameters
echo WEIGHTS_DIR: ${WEIGHTS_DIR?$0: WEIGHTS_DIR not specified}
echo MLF_TRAIN: ${MLF_TRAIN?$0: MLF_TRAIN not specified}
echo SCP_TRAIN: ${SCP_TRAIN?SCP_TRAIN not specified}
echo LEARNRATE: ${LEARNRATE?$0: LEARNRATE not specified}
echo PHONELIST: ${PHONELIST?$0: PHONELIST not specified}
echo FEATURE_TRANSFORM:   ${FEATURE_TRANSFORM?$0: FEATURE_TRANSFORM not specified}
echo FRM_EXT:   ${FRM_EXT?$0: FRM_EXT not specified}

##############################
#define implicit configuration
echo MAXITERATION: ${MAXITERATION:=1}
echo RANDOMIZE: ${RANDOMIZE:=TRUE}
echo BUNCHSIZE: ${BUNCHSIZE:=256}
echo CACHESIZE: ${CACHESIZE:=40960}
echo TRACE: ${TRACE:=5}
echo TNET_FLAGS: ${TNET_FLAGS:=-A -D -V}
echo HALVING_FACTOR: ${HALVING_FACTOR:=1.0}
echo WEIGHTCOST: ${WEIGHTCOST:=1e-6}

#############################################
#runs the training commad, parses the accuracy
function run_tnet_parse_accu {
  local cmd=$1;
  echo %%%%%%
  echo $cmd
  echo %%%%%%
  local logfile=$(mktemp);
  $cmd | tee $logfile | sed 's|^|  |'
  #parse the logfile to get accuracy: 
  ACCU=$(cat $logfile | grep 'Xent:' | tail -n 1 | sed 's|.*\[\(.*\)%\].*|\1|')
  rm $logfile
  if [[ $ACCU == "" ]]; then
    echo "Error, No accuracy returned, terminating..."
    exit 1
  fi
}


############################################

#create weight directory
rm -r ${WEIGHTS_DIR}-old
mv ${WEIGHTS_DIR} ${WEIGHTS_DIR}-old
[ -d ${WEIGHTS_DIR} ] || mkdir ${WEIGHTS_DIR}

nnet=${WEIGHTS_DIR}/nnet_tr
echo "">${nnet}

# target number
TN=${TOPOLOGY[${#TOPOLOGY[@]}-1]}

#pretrain layers
for N in $(seq 0 $((${#TOPOLOGY[@]}-3))); do
  
  # initialize 
  python tools/gen_mlp_init.py --dim=${TOPOLOGY[N]}:${TOPOLOGY[N+1]}:$TN --gauss --negbias > ${WEIGHTS_DIR}/L${N}
  awk -v TN=$TN 'BEGIN{flag=0;}NR==FNR{if(flag==1){}else{if($2==TN){flag=1;}else{print;}}}NR!=FNR{print;}' ${nnet} ${WEIGHTS_DIR}/L${N} > ${nnet}_L$N
  nnet=${nnet}_L$N

  nnet_this=$nnet
  for M in $(seq 1 $MAXITERATION);do
  nnet_next=${nnet}_iter${M}_lr${LEARNRATE[$M]}
  cmd="$TNET_ROOT $TNET_FLAGS -T $TRACE \
   -H ${nnet_this} \
   -I $MLF_TRAIN \
   -L '*/' -X lab \
   -S $SCP_TRAIN \
   --LEARNINGRATE=${LEARNRATE[$M]} \
   ${LEARNRATEFACTORS:+--LEARNRATEFACTORS=$LEARNRATEFACTORS} \
   ${MOMENTUM:+--MOMENTUM=$MOMENTUM} \
   ${WEIGHTCOST:+--WEIGHTCOST=$WEIGHTCOST} \
   --BUNCHSIZE=$BUNCHSIZE \
   --CACHESIZE=$CACHESIZE \
   --RANDOMIZE=$RANDOMIZE \
   --OUTPUTLABELMAP=$PHONELIST \
   --TARGETMMF=${nnet_next} \
   --STARTFRMEXT=$FRM_EXT \
   --ENDFRMEXT=$FRM_EXT \
   ${FEATURE_TRANSFORM:+--FEATURETRANSFORM=$FEATURE_TRANSFORM} \
   ${STK_CONF:+-C $STK_CONF} \
   ${THREADS:+--THREADS=$THREADS} \
   ${CONFUSIONMODE:+--CONFUSIONMODE=$CONFUSIONMODE} \
   "

  run_tnet_parse_accu "$cmd"
  accu_train=$ACCU
  echo "TR accuracy:  $ACCU"

  mv ${nnet_next} ${nnet_next}_tr$ACCU
  nnet_this=${nnet_next}_tr$ACCU  

  done

  cat ${nnet_this} > ${nnet}  
  #LEARNRATE= $(awk 'BEGIN{print('$LEARNRATE'*'$HALVING_FACTOR')}')

done

