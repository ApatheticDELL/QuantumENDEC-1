#SAME GEN CLC
ALE=$(cat geo.txt | cut -c1-2);
case $ALE in
59)
echo BC
echo -n "080000" >> same.txt
;;
48)
echo AB
echo -n "070000" >> same.txt
;;
46)
echo MB
echo -n "050000" >> same.txt
;;
13)
echo NB
echo -n "010000" >> same.txt
;;
10)
echo NL
echo -n "020000" >> same.txt
;;
61)
echo NT
echo -n "090000" >> same.txt
;;
12)
echo NS
echo -n "010000" >> same.txt
;;
62)
echo NU
echo -n "090000" >> same.txt
;;
35)
echo ON
echo -n "040000" >> same.txt
;;
11)
echo PE
echo -n "010000" >> same.txt
;;
47)
echo SK
echo -n "060000" >> same.txt
;;
24)
echo QC
echo -n "030000" >> same.txt
;;
60)
echo YT
echo -n "090000" >> same.txt
;;
*)
echo UNKNOWN
echo -n "000000" >> same.txt
;;
esac

exit 0
