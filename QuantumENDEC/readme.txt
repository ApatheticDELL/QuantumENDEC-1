This is QuantumENDEC CAP-CP Edition, created by ApatheticDELL.
Version 2.0.

And this is the readme file.

	SECTION 0: Few things to say
After a lot of looking through coding fourms, chinese food, almost wanting to throw the computer out the window because some minor one line thing was screwing up the entire program, QuantumENDEC.
Yep, its a program that captures alerts and turns em into audio files or something like that.
- Don't broadcast SAME headers on air (on radio frequiencies). FCC boutta whip ya if you do.
- Don't make your safety and life depend on this dum program, it's not that great.
Overall, this is for like, hobby stuff with EAS and things, this program isn't that great anyway. Please feel free to like, add comments to help make this software a little better.
So you could say this is somewhat of a modified version of libmarleu's BashENDEC.
Without OpenBrodcaster, BashENDEC, and the Pelmorex NAADs LMD user guide PDF existing, QuantumENDEC would not be possible.

	SECTION 1: Introduction
QuantumENDEC is your Digital Emergency Alert ENDEC, this version is designed for CAP-CP relay.
Using a python code, and bash, the ENDEC will connect to the Pelmorex NAAD TCP streams, and capture the XML files (Python moni.py) and then the bash code will pick it up and decode it, then encode it to a S.A.M.E alert, and a discord message.
This is like, my first coded, so-called, software I ever wrote (kinda). And like, I'm very not experienced coder so like, there could be some improvements.
QuantumENDEC CAP-CP Edition is built off BashENDEC from libmarleu on GitHub.
Good luck.

	SECTION 2: SETUP
The first thing you want to do is to CD into the QuantumENDEC folder and run "bash install.sh".
This will install the necessary dependencies you need to run QuantumENDEC. There will be a prompt to input the root/sudo password; due to sudo commands to install the stuff.

Next, you want to open "relay.sh" in a text processer or anything you use that can edit code and change some of the strings and configurations; there are notes (#notes) in the code that will give you some insight on what the commands do.
	(!) If you are using OpenBroadcaster you can use the newsfeed override function (notes in relay.sh) to make the alerts interrupt the broadcast. Just make sure obplayer alerts function is off.

Now you should be ready.

	SECTION 3: Launching QuantumENDEC
Just cd into the QuantumENDEC folder and run "bash QuantumENDEC" or "sh QuantumENDEC" to start it, there will be a title screen and you'll have to follow a little prompt.

	SECTION 4: OBS integration.
One thing, when I say OpenBroadcaster, it's not OBS (Open Broadcasting Studio), though now I'm talking about OBS.
There are 2 folders in QuantumENDEC called PerWin and Win, these are folders made to implement EAS in OBS, there would be 3 files in Win and 2 in PerWin.

Win, there is the automatically generated PNG of the alert map, the TXT file of the alert, and the background for the alert.
PerWin, there is just the automatically generated PNG or the alert map, and the alert text.

How to set up automatic alerting in OBS, open OBS and make 1 image source, link it with the map in Win. Then make a text object, and set it to read from a file, link it to the OBS.txt. Then link the image in Win with the background in another image source. And that's it, with this setup, when an alert relays, the graphics will appear for a moment then disappear. (Will automatically disappear when the delOBS.sh bash file is running, so make sure its running when you want that.)

PerWin is there so you can show the alert graphics at your command because the files in PerWin don't get deleted.
To setup PerWin on OBS, its the same as setting up Win, just create new sources for PerWin files.

They can work over Network sharing too if you are running OBS on another computer on the same network.
