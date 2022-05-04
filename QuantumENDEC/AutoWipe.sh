while true
do
	clear
	rm xmls/*
	echo "Sending System test"
	rm alerts/*
	rm xmls/*
	rm sameold.txt
	cp TESTER.xml xmls/alert.xml
	echo "Last QE refresh: $(date)"
	sleep 4h
done

#You can change how long until next system check by changing the number after the last sleep command before done. The h means hours, tho you can change that to m for minutes.
