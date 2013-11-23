
if [[ $# -ne 1 ]]; then
    echo " [Input Error] : please give the NN to stat";
    echo " ENVIR : VERBOSE TMPDIR"
    exit;
fi

TMPDIR=${TMPDIR:=tmp}
DEBUG=${DEBUG:=0}

if [[ $DEBUG == 1 ]]; then
    set -x
fi

mkdir -p $TMPDIR
NN=$1
NAME=$(basename ${NN%%.*})
echo name of NN : $NAME
HiddenLB=$(( $(grep 'm ' $NN | wc -l) - 1 ))
echo "Number of hidden layers : " $HiddenLB
SS=$(grep 'm ' $NN | awk ' BEGIN { s=""; } { if (NR==1) s=s""$3; else s=s"_"$2; } END { print s } ')
echo "NN topology : " $SS
Mnum=$(grep 'm ' $NN | awk ' BEGIN { sum = 0; } { sum = sum + $2 * $3; } END { print sum; } ')
echo "Number of parameter in transformation Matrice : " $Mnum
cat $NN | awk ' { if (NF==2 && $1=="v") printf("%s ", $0); else print $0; } ' > ${TMPDIR}/${NAME}.tmp

cd ${TMPDIR}
cat ${NAME}.tmp | awk ' BEGIN { mFile = "m"; vFile = "v"; mI = 0; vI = 0; } 
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
cd ..

if [[ $DEBUG == 0 ]]; then
    echo "final clean up..."
    rm -r ${TMPDIR}
fi

