vs=$1
kd=$2
bigkd=$(echo $kd | tr a-z A-Z)
echo "~o <VecSize> $vs <${bigkd}>"
echo "~h \"$kd\""
echo "<BeginHMM>"
echo " <NumStates> 5"
for st in 2 3 4;
do
echo "  <State> $st"
echo 0 | awk -v vec=$vs '{printf "   <Mean> %d\n    ",vec;for(i=1;i<=vec;i++) printf "0.0 ";printf "\n   <Variance> %d\n    ",vec;for(i=1;i<=vec;i++) printf "1.0 ";printf "\n";}'
done
echo "<TransP> 5"
echo "0.0 1.0 0.0 0.0 0.0"
echo "0.0 0.6 0.4 0.0 0.0"
echo "0.0 0.0 0.6 0.4 0.0"
echo "0.0 0.0 0.0 0.7 0.3"
echo "0.0 0.0 0.0 0.0 0.0"
echo "<EndHMM>"
