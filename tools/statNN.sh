if [[ $# -ne 1 ]]; then
    echo " [Input Error] : please give the NN to stat";
    exit;
fi
NN=$1

HiddenLB=$(( $(grep 'm ' $NN | wc -l) - 1 ))
echo "Number of hidden layers : " $HiddenLB
SS=$(grep 'm ' $NN | awk ' BEGIN { s=""; } { if (NR==1) s=s""$3; else s=s"_"$2; } END { print s } ')
echo "NN topology : " $SS
Mnum=$(grep 'm ' $NN | awk ' BEGIN { sum = 0; } { sum = sum + $2 * $3; } END { print sum; } ')
echo "Number of parameter in transformation Matrice : " $Mnum

echo "final clean up..."

