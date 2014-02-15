#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: pruning \$2 nodes by computeWSUM from nnet.final to \$1.init "
    exit
fi

#different from nodePrune, we prune the first pNumber of all nodes(not from each layer)
nn=${1:nnet_tr_L0_L1_L2_L3WSPr5000}
pNumber=$2
lNumber=$(grep 'm ' nnet.final | wc -l)
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
/home/matlab/bin/matlab -nodesktop -nosplash -nojvm -r "computeWSum(${lNumber}, 'WSum.out');quit;";
/home/matlab/bin/matlab -nodesktop -nosplash -nojvm -r "metricNodeDel(${lNumber}, 'WSum.out', 'weights/${nn}-pru', ${pNumber});quit;";
cp weights/${nn}-pru ${nn}.init
rm v?;
rm m?;
echo ================now greping ${nn}.init==============
grep 'm ' ${nn}.init
echo =====================================================

