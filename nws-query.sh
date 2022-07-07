#!/bin/env bash
#dependencies: w3m, sed, less

#argument 1 is query

set -o errexit
set -o pipefail
set -o nounset
#set -o xtrace # uncomment for debugging

if [ -s "${nwslocal:-}NWS_${1}" ]
then less "${nwslocal:-}NWS_${1}"
else w3m "https://nws.uzi.uni-halle.de/search?utf8=✓&q=${1}&m=&t=&d=&type=&ntype=&cat=&ncat=&c=&v=&merge=on" |  sed '1,/^NWS/ d' | less
fi

exit 0
