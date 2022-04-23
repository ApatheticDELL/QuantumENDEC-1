#!/bin/bash
#MAKE SURE YOU READ THESE NOTES FOR FIRST TIME USE

#THIS LITTLE PART IS THE CONFIG#
CALSIGN="NCC/1701" #YOUR CALLSIGN FOR THE SAME HEADER, MAKSURE THERE IS NO - (DASHES). USE / (FORWARD SLASH) INSTEAD.
WEBHOOK_URL="webhook.com" #WEBHOOK URL FOR YOUR DISCORD SERVER!
BOTNAME="Emergency Alert System" #TO CHANGE THE NAME OF THE DISCORD BOT, IF YOU WANT TO NAME IT SOMETHING COOL.
CLSS="clear" #WHEN ON "clear" IT WILL CLEAR THE TERMINAL WINDOW AT SOME POINTS, CHANGE/REMOVE IT FOR DEBUGGING REASONS.

$CLSS
date
mv relay.xml relayed.xml
mv ipaws.xml ipawsOLD.xml

#DIFF=$(diff -q xmls/alert.xml ipawsOLD.xml);
DIFF=$(diff -q `ls -dt1 xmls/* | head -1` ipawsOLD.xml);

if [[ $DIFF == *"differ"* ]]; then
	echo "New alert detected"
else
	inotifywait xmls -e create -e moved_to
	echo "New alert detected"
fi

#cp -p xmls/alert.xml ipaws.xml
cp `ls -dt1 xmls/* | head -1` ipaws.xml

$CLSS

#cmp --silent -- "xmls/alert.xml" "ipawsOLD.xml"

if grep "AKR24-EAS-SYSTEMTEST-420" ipaws.xml; then
	#This will send the system check message to your discord bot (if you have one) if not, you can leave it. These tests happens every 3 hours but can be changed in AutoWipe.sh
	echo "System check!"
	message=$(date +"QuantumENDEC: SYSTEM CHECK | %T %Z");
	curl \
	  -F 'payload_json={"username": "'"$BOTNAME"'", "content": "'"$message"'"}' \
	  $WEBHOOK_URL
	$CLSS
	echo "System check was sent..."
	date
	rm xmls/*
	exit 0
else
	echo "Alert Confirmed"
fi

echo "Getting EN (English)" #or change to FR (French) if you want if you changed the bottom. (optional, won't affect operation, but can avoid confusion.)
tr '\n' ' ' < ipaws.xml | sed 's/>[ \t]*</></g' | sed '/<\/\n/g' > prerelay.xml
sed --in-place 's/^.*en-CA/<alert><info><language>en-CA/' prerelay.xml #change to fr-CA to get only french, or hash/remove this line to get whatever comes first... but be warned, you may have to change the TTS function near the end of the file.
grep -oPm1 '(?<=<info>).*?(?=</info>)' prerelay.xml | head -n 1 > relay.xml #| xargs -0 echo -n

#remove exit 0 if want to relay minor alerts and/or past alerts.
SEVERITY=$(grep -oPm1 "(?<=<severity>)[^<]+" relay.xml);
case $SEVERITY in
Minor) echo "Minor, no alert" ; exit 0 ;;
*) echo "yes" ;;
esac

URGENCY=$(grep -oPm1 "(?<=<urgency>)[^<]+" relay.xml);
case $URGENCY in
Past) echo "Past, no alert" ; exit 0 ;;
*) echo "yes" ;;
esac

#this is to prevent alerts with missing peices.
if grep -oPm1 "(?<=<headline>)[^<]+" relay.xml; then
    echo "The alert has a headline!"
else
    echo "THE ALERT IS MISSING THE HEADLINE!"
    exit 0
fi

$CLSS
#IMPORTANT! READ THESE OVER BEFORE LAUNCHING!!!
#TO NOT RELAY IN A SELECTED PROVINCE, INPUT "exit 0" UNDER "echo ??" BELOW...
cat relay.xml | grep -oP '(?<=<geocode><valueName>profile:CAP-CP:Location:0.3</valueName><value>).*?(?=</value>)' | xargs echo -n > geo.txt
ALE=$(cat geo.txt | cut -c1-2);
case $ALE in
59)
echo BC
#exit 0
;;
48)
echo AB
#exit 0
;;
46)
echo MB
#exit 0
;;
13)
echo NB
#exit 0
;;
10)
echo NL
#exit 0
;;
61)
echo NT
#exit 0
;;
12)
echo NS
#exit 0
;;
62)
echo NU
#exit 0
;;
35)
echo ON
#exit 0
;;
11)
echo PE
#exit 0
;;
47)
echo SK
#exit 0
;;
24)
echo QC
#exit 0
;;
60)
echo YT
#exit 0
;;
*)
echo UNKNOWN
;;
esac

#if new areas issued check.
if grep "EC-MSC-SMC:1.1:Newly_Active_Areas" relay.xml; then
	NEWAREAS=$(cat relay.xml | grep -oP '(?<=<parameter><valueName>layer:EC-MSC-SMC:1.1:Newly_Active_Areas</valueName><value>).*?(?=</value>)' | head -n 1 | xargs echo -n);
	case $NEWAREAS in
	"") $CLSS ; echo "No new areas, exiting" ; exit 0 ;;
	*) echo "There are new areas, proceed" ;;
	esac
else
	echo "May not be an EC alert, so proceed"
fi

#to check WXR CA activation
cat relay.xml | grep -oP '(?<=<parameter><valueName>layer:EC-MSC-SMC:1.1:Newly_Active_Areas</valueName><value>).*?(?=</value>)' | head -n 1 | xargs echo -n > NewAreas.txt
bash WXRC-CLC.sh

if [ -s relay.xml ]
then
	echo "Alert Is Valid"
else
	cp relay.xml relayERROR.xml #to check what went worng
	exit 0
fi

if grep "SAME" relay.xml; then
	echo -n "ZCZC-WXR-" > same.txt
	cat relay.xml | grep -oP '(?<=<eventCode><valueName>SAME</valueName><value>).*?(?=</value>)' | head -n 1 | xargs echo -n >> same.txt
	echo -n "-" >> same.txt
else
	$CLSS
	echo "Time to encode decode"
	EVE=$(cat relay.xml | grep -oP '(?<=<eventCode><valueName>profile:CAP-CP:Event:0.4</valueName><value>).*?(?=</value>)' | head -n 1 | xargs echo -n);
	case $EVE in
	civilEmerg) echo -n "ZCZC-CIV-CEM-" > same.txt;;
	terrorism) echo -n "ZCZC-CIV-CDW-" > same.txt;;
	animalDang) echo -n "ZCZC-CIV-CDW-" > same.txt;;
	wildFire) echo -n "ZCZC-CIV-FRW-" > same.txt;;
	industryFire) echo -n "ZCZC-CIV-FRW-" > same.txt;;
	urbanFire) echo -n "ZCZC-CIV-FRW-" > same.txt;;
	forestFire) echo -n "ZCZC-CIV-FRW-" > same.txt;;
	stormSurge) echo -n "ZCZC-WXR-SSW-" > same.txt;;
	flashFlood) echo -n "ZCZC-WXR-FFW-" > same.txt;;
	damOverflow) echo -n "ZCZC-CIV-FFW-" > same.txt;;
	earthquake) echo -n "ZCZC-CIV-EQW-" > same.txt;;
	magnetStorm) echo -n "ZCZC-CIV-CDW-" > same.txt;; #this one has no fitting SAME event code
	landslide) echo -n "ZCZC-CIV-FLW-" > same.txt;;
	meteor) echo -n "ZCZC-CIV-CDW-" > same.txt;; #this one has no fitting SAME event code
	tsunami) echo -n "ZCZC-WXR-TSW-" > same.txt;;
	lahar) echo -n "ZCZC-CIV-VOW-" > same.txt;;
	pyroclasticS) echo -n "ZCZC-CIV-VOW-" > same.txt;;
	pyroclasticF) echo -n "ZCZC-CIV-VOW-" > same.txt;;
	volcanicAsh) echo -n "ZCZC-CIV-VOW-" > same.txt;;
	chemical) echo -n "ZCZC-CVI-HMW-" > same.txt;;
	biological) echo -n "ZCZC-CIV-HMW-" > same.txt;;
	radiological) echo -n "ZCZC-CIV-RHW-" > same.txt;;
	explosives) echo -n "ZCZC-CIV-HMW-" > same.txt;;
	fallObject) echo -n "ZCZC-CIV-HMW-" > same.txt;;
	drinkingWate) echo -n "ZCZC-CIV-CEM-" > same.txt;; #this one has no SAME fitting event code
	amber) echo -n "ZCZC-CIV-CAE-" > same.txt;;
	hurricane) echo -n "ZCZC-WXR-HUW-" > same.txt;;
	thunderstorm) echo -n "ZCZC-WXR-SVR-" > same.txt;;
	tornado) echo -n "ZCZC-WXR-TOR-" > same.txt;;
	testMessage) echo -n "ZCZC-EAS-ADR-" > same.txt;;
	911Service) echo -n "ZCZC-CIV-TOE-" > same.txt;;
	weather)
	echo "CAP-CP weather alert relay is off..."
	exit 0
	;;
	other)
	#to make sure a useless alert isn't relayed, you could change this.
	if grep "<severity>Extreme</severity>" relay.xml; then
		echo -n "ZCZC-WXR-CDW-" > same.txt
	else
		echo -n "ZCZC-WXR-CEM-" > same.txt
	fi
	;;
	*)
	if grep "<severity>Extreme</severity>" relay.xml; then
		echo -n "ZCZC-WXR-CDW-" > same.txt
	else
		echo -n "ZCZC-WXR-CEM-" > same.txt
	fi
	;;
	esac
fi
#ZCZC-WWW-WWW-
#now gen CLC (CA-FIPS) code
if grep "layer:EC-MSC-SMC:1.0:CLC" relay.xml; then
	cat relay.xml | grep -oP '(?<=<geocode><valueName>layer:EC-MSC-SMC:1.0:CLC</valueName><value>).*?(?=</value>)' | xargs echo -n >> same.txt
else
	#code that converts geocodes to CLC (not fully done)
	bash SAMEgen-CLC.sh
fi
#ZCZC-WWW-WWW-000000
echo -n "+" >> same.txt
echo -n "0600" >> same.txt
echo -n "-" >> same.txt
TZ='UTC' date +%j%H%M | xargs echo -n >> same.txt
echo -n "-" >> same.txt
echo -n "$CALSIGN" >> same.txt #YOUR CALLSIGN
echo -n "-" >> same.txt
sed --in-place 's/://g' same.txt
sed --in-place 's/ /-/g' same.txt
cat same.txt
#ZCZC-WWW-WWW-000000+0600-0000000-WXV24/IP-

echo "Generating Header"
rm same.wav
rm same.mp3
SAMEX=$(cat same.txt);
echo "$SAMEX" | minimodem --tx same --startbits 0 --stopbits 0 --sync-byte=0xAB -f same.wav
ffmpeg -y -i same.wav -vn -ar 48000 -ac 2 -b:a 224k same.mp3

echo "Checking header"
SAMECHECK=0
cmp --silent same.txt sameold.txt || SAMECHECK=1
case $SAMECHECK in
0) echo "This SAME code has been already used!" ; exit 0 ;;
1) $CLSS ; echo "This SAME code is new!" ; mv same.txt sameold.txt ;;
*) echo "SAMECHECK - This should not happen? Check code..." ;;
esac

rm audio.wav
rm audio.mp3
cp EASbk.png Win/EASbk.png

if grep "Broadcast Audio" relay.xml; then
	echo "BROADCAST AUDIO"
	cat relay.xml | grep -oP '(?<=<valueName>layer:SOREM:1.0:Broadcast_Text</valueName><value>).*?(?=</value>)' | head -n 1 > audio.txt
	cp audio.txt Win/OBS.txt
	echo "grabbing audio"
	BCA=$(grep -oPm1 "(?<=<uri>)[^<]+" relay.xml | head -n 1);
	wget -c -A '*.mp3' -r -l 1 -nd $BCA -O audio.mp3
else
	echo "No Broadcast audio"
	rm audio.txt
	
	if grep "Broadcast_Text" relay.xml; then
		cat relay.xml | grep -oP '(?<=<valueName>layer:SOREM:1.0:Broadcast_Text</valueName><value>).*?(?=</value>)' | head -n 1 > audio.txt
		cp audio.txt Win/OBS.txt
	else
		echo "No broadcast text! Using alternitive methood..."
		
		EFF=$(cat relay.xml | grep -oPm1 "(?<=<effective>)[^<]+" | head -n 1);
		LOL=$(date -u -d $EFF "+At %l:%M %p Universal Coordinated Time, %A %B %d %Y.");
		echo $LOL > audio.txt
		cat relay.xml | grep -oPm1 "(?<=<senderName>)[^<]+" | head -n 1 >> audio.txt
		echo -n " has issued a " >> audio.txt
		cat relay.xml | grep -oPm1 "(?<=<headline>)[^<]+" | head -n 1 >> audio.txt
		echo -n " for the following localities in " >> audio.txt
		cat relay.xml | grep -oPm1 "(?<=<valueName>layer:EC-MSC-SMC:1.0:Alert_Coverage</valueName><value>).*?(?=</value)" | head -n 1 >> audio.txt
		echo -n ". " >> audio.txt
		cat relay.xml | grep -oPm1 "(?<=<areaDesc>)[^<]+" > loca.txt
		sed --in-place '$!s/$/,/' loca.txt
		cat loca.txt >> audio.txt
		echo -n ". " >> audio.txt
		cat relay.xml | grep -oPm1 "(?<=<description>)[^<]+" | head -n 1 >> audio.txt
		cat relay.xml | grep -oPm1 "(?<=<instruction>)[^<]+" | head -n 1 >> audio.txt
		
		EFF=$(cat relay.xml | grep -oPm1 "(?<=<effective>)[^<]+" | head -n 1);
		LOL=$(date -u -d $EFF "+At %l:%M %p Universal Coordinated Time, %A %B %d %Y.");
		echo $LOL > OBS.txt
		cat relay.xml | grep -oPm1 "(?<=<senderName>)[^<]+" | head -n 1 >> OBS.txt
		echo -n " has issued a " >> OBS.txt
		cat relay.xml | grep -oPm1 "(?<=<headline>)[^<]+" | head -n 1 >> OBS.txt
		echo -n " in " >> OBS.txt
		cat relay.xml | grep -oPm1 "(?<=<valueName>layer:EC-MSC-SMC:1.0:Alert_Coverage</valueName><value>).*?(?=</value)" | head -n 1 >> OBS.txt
		echo -n " for " >> OBS.txt
		cat loca2.txt >> OBS.txt
		tr '\n' ' ' < OBS.txt | sed 's/>[ \t]*</></g' | sed '/<\/\n/g' > Win/OBS.txt
		cp Win/OBS.txt PerWin/PerOBS.txt
	fi
	#espeak -v en-us+7
	#flite -f audio.txt -voice slt -o audio.wav
	sed --in-place 's/###/ /g' audio.txt
	cat audio.txt | pico2wave -w=audio.wav
	ffmpeg -y -i audio.wav -filter:a "volume=2" -vn -ar 48000 -ac 2 -b:a 224k audio.mp3
fi

#Here you can change prefix message for your discord bot!
SAME=$(cat sameold.txt);
tr '\n' ' ' < audio.txt | sed 's/>[ \t]*</></g' | sed '/<\/\n/g' > 2aud.txt
echo -n "[SAME=$SAME] ***EMERGENCY ALERT:*** " > Discord.txt

if grep -E 'russia|nuclear|Russia|russian|Russian|Nuclear' relay.xml; then
	echo -n "[ITS THE END OF THE WORLD AS WE KNOW IT... AND I FEEL FINEEE] @here <@&882651939224051712> [Holy fuck @everyone shit might be going down! So please read the following message...] **EMERGENCY ALERT...**" > Discord.txt
else
	echo "nah"
fi

#You can change the prefix message depending on severity
case $SEVERITY in
Extreme)
echo -n "[<@&882651939224051712> $SAME] **EMERGENCY ALERT RELAY...** " > Discord.txt
;;
Severe)
echo -n "[<@&882651939224051712> $SAME] **EMERGENCY ALERT RELAY...** " > Discord.txt
;;
esac

tr '\n' ' ' < audio.txt | sed 's/>[ \t]*</></g' | sed '/<\/\n/g' > 2aud.txt
cat 2aud.txt >> Discord.txt
sed --in-place 's/;/./g' Discord.txt
message=$(cat Discord.txt);

curl \
  -F 'payload_json={"username": "'"$BOTNAME"'", "content": "'"$message"'"}' \
  -F "file1=@ipaws.xml" \
  $WEBHOOK_URL

dt=$(date '+%d-%m-%YT%H-%M-%S');
echo "making alert$dt"

if grep "Broadcast Audio" relay.xml; then
	echo "file 'SLI.mp3'#file 'same.mp3'#file 'SLI.mp3'#file 'same.mp3'#file 'SLI.mp3'#file 'same.mp3'#file 'SLI.mp3'#file 'attn.mp3'#file 'EAScan.mp3'#file 'audio.mp3'#file 'EOM.mp3'" > Alist.txt
else
	case $SEVERITY in
	Extreme)
	echo "file 'SLI.mp3'#file 'same.mp3'#file 'SLI.mp3'#file 'same.mp3'#file 'SLI.mp3'#file 'same.mp3'#file 'SLI.mp3'#file 'SLI.mp3'#file 'attn.mp3'#file 'SLI.mp3'#file 'audio.mp3'#file 'EOM.mp3'" > Alist.txt
	;;
	*)
	echo "file 'SLI.mp3'#file 'same.mp3'#file 'SLI.mp3'#file 'same.mp3'#file 'SLI.mp3'#file 'same.mp3'#file 'SLI.mp3'#file 'SLI.mp3'#file 'attnQ.mp3'#file 'SLI.mp3'#file 'audio.mp3'#file 'EOM.mp3'" > Alist.txt
	;;
	esac
fi

tr '#' '\n' < Alist.txt | xargs -0 echo -n > Alist1.txt
ffmpeg -f concat -i Alist1.txt -vn -ar 48000 -ac 2 -b:a 224k alerts/alert"$dt".mp3

#this command is for interupting openbroadcaster program with alert
#cp alerts/alert"$dt".mp3 /home/[username]/.openbroadcaster/news_feed_override

bash mapgen.sh
cp mapwarn.png Win/mapwarn.png
cp mapwarn.png PerWin/mapwarn.png

curl \
  -F "file1=@mapwarn.png" \
  -F "file2=@alerts/alert$dt.mp3" \
  $WEBHOOK_URL

$CLSS
echo "Last alert was..."
date
exit 0

#You made it to the end of this file.



