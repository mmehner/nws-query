#!/bin/sh
#dependencies: w3m, sed
#usage: execute in in this directory
#arguments: pass scrapefolder as argument 1


while IFS= read -r l
do
    if [ -s "${1}NWS_${l}" ]
    then echo "$l : Already saved locally"
    else echo "$l : Not yet saved … querying NWS"
	 w3m "https://nws.uzi.uni-halle.de/search?utf8=✓&q=${l}&m=&t=&d=&type=&ntype=&cat=&ncat=&c=&v=&merge=on" |  sed '1,/^Nachtragswörterbuch des Sanskrit/ d' > "${1}NWS_${l}"
	 count=1
	 while [ ! -s "${1}NWS_${l}" ] && [ "$count" -lt 10 ]
	 do
	     echo "Failed, retrying, run ${count}"
	     w3m "https://nws.uzi.uni-halle.de/search?utf8=✓&q=${l}&m=&t=&d=&type=&ntype=&cat=&ncat=&c=&v=&merge=on" |  sed '1,/^Nachtragswörterbuch des Sanskrit/ d' > "${1}NWS_${l}"
	     count=$((count + 1))
	     sleep 1
	 done
	 sleep 1
	 echo "… saved."
    fi 
done < index_pw-PW_sorted_uniq.txt

if [ "$(find "${1}" -type f -empty)" ]
then
    echo "Permanently failed requests, remove empty files and rerun at a later time:"
    find "${1}" -type f -empty
else
    echo "All done!"
fi
