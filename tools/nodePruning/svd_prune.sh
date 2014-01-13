set -x
#different from nodePrune, we prune the first pNumber of all nodes(not from each layer)
nn=${1:-nnet_tr_L0_L1_L2_L3Play75%};
lNumber=${2:-4};
rank=$3
lr=${4:-0.8}
wc=${5:-0.000001}
inputLayer=1353;
outLayerSL=4;
echo ===========now greping nnet.final===================
grep 'm ' nnet.final
echo =====================================================
rm m?;
rm v?;
#sed -n "$kk,$((${kk} + 1))p" nnet.final > 1    no use
mv nnet.final nnet.final.bak
cat nnet.final.bak | awk ' { if (NF==2 && $1=="v") printf("%s ", $0); else print $0; } ' > nnet.final
cat nnet.final | awk ' BEGIN { mFile = "m"; vFile = "v"; mI = 0; vI = 0; } 
	{ if ($1 == "m") {
	 	mI = mI + 1;
	  }
	  else if ($1 == "v") {
		vI = vI + 1;
		for (i = 3;i <= NF;i++)
			printf("%lf ", $i) >> vFile""vI;
		printf("\n") >> vFile""vI;
	  }		
	  else if (NF <= 5) {
	  }
	  else {
	  	print $0 >> mFile""mI;
	  }
	}';
mkdir -p weights;
/home/matlab/bin/matlab -nodesktop -nosplash -nojvm -r "doSvd(${lNumber}, ${rank}, 'weights/${nn}-pru');quit;";
cp weights/${nn}-pru ${nn}.init
rm v?;
rm m?;
echo ================now greping ${nn}.init==============
grep 'm ' ${nn}.init
echo =====================================================
#cd ../../decode
#./README-INIT-play ${nn}
#cd ../finetune/${nn}
./finetune-play-svd ${nn} $lr $wc
cd ../../decode
./README-play ${nn}
str=$(grep 'm ' ${nn}/nnet.final | awk -v oL=${outLayerSL} -v inp=${inputLayer} ' BEGIN { s=inp } { s=s"K"$2 } END { s=substr(s,1,length(s)-oL); print s; } ');
../../calW.py ${str}
echo press enter to display INIT..
read rub
cat ${nn}-INIT/eval_phone_loop_result

