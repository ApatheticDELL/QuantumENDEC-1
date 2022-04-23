while true
do
	if [ -s Win/OBS.txt ]
	then
	        echo "Start countdown to delete!"
	else
	        echo "Standing by"
	        inotifywait Win -e create -e moved_to
	        echo "Start countdown to delete!"
	fi
	sleep 60
	rm Win/*
	clear
	echo "Deleted"
	exit 0
done
