cat relay.xml | grep -oP '(?<=<geocode><valueName>profile:CAP-CP:Location:0.3</valueName><value>).*?(?=</value>)' | xargs echo -n > geo.txt
ALE=$(cat geo.txt | cut -c1-2);

ALERT1=$(cat relay.xml | grep -oPm1 "(?<=<headline>)[^<]+" | head -n 1);
echo "lat,lon" > poly1.txt
cat relay.xml | grep -oP '(?<=<polygon>).*?(?=</polygon>)' >> poly1.txt
tr ' ' '\n' < poly1.txt | xargs -0 echo -n > poly.csv

case $ALE in
59)
echo BC
AREA=CA.BC
;;
48)
echo AB
AREA=CA.AB
;;
46)
echo MB
AREA=CA.MB
;;
13)
echo NB
AREA=CA.NB
;;
10)
echo NL
AREA=CA.NL
;;
61)
echo NT
AREA=CA.NT
;;
12)
echo NS
AREA=CA.NS
;;
62)
echo NU
AREA=CA.NU
;;
35)
echo ON
AREA=CA.ON
;;
11)
echo PE
AREA=CA.PE
;;
47)
echo SK
AREA=CA.SK
;;
24)
echo QC
AREA=CA.QC
;;
60)
echo YT
AREA=CA.YT
;;
*)
echo UNKNOWN
AREA=CA
;;
esac

gmt begin premap png
	gmt coast -R"$AREA"+r0.50 -Ggray -Sblue -N1/1p,black -N2/0.5p -W -Da
	gmt plot poly.csv -h1 -i1,0 -Gred@50 -Wthinnest -l"$ALERT1"
	END
gmt end

convert premap.png -resize 1280x962! mapwarn.png
exit 0
