if [[ $# -ne 1 ]]; then
    echo " [Input Error] : please give the NN to stat";
    exit;
fi
NN=$1
copy_NN_local=1

if [[ $copy_NN_local == 1 ]]; then
    echo "copy || $1 || to local nnet.final..."
    cp $NN ./nnet.final
    NN=nnet.final
    echo copy complete
fi

HiddenLB=$(( $(grep 'm ' $1 | wc -l) - 1 ))
echo "Number of hidden layers : " $HiddenLB
SS=$(grep 'm ' $1 | awk ' BEGIN { s=""; } { if (NR==1) s=s""$3; else s=s"_"$2; } END { print s } ')
echo "NN topology : " $SS
Mnum=$(grep 'm ' $1 | awk ' BEGIN { sum = 0; } { sum = sum + $2 * $3; } END { print sum; } ')
echo "Number of parameter in transformation Matrice : " $Mnum

echo "final clean up..."
if [[ $copy_NN_local == 1 ]]; then
    rm $NN
fi


