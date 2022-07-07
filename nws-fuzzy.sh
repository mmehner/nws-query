#!/bin/env bash
#dependencies: fzf, sed, less

set -o errexit
set -o pipefail
set -o nounset
#set -o xtrace # uncomment for debugging

[ -z "${nwslocal}"  ] && echo "environmental variable nwslocal not set, exiting." && exit

pushd "${nwslocal}" || exit

while true; do
    p=""
    p=$(fzf --preview 'cat {1}')
    [ -z "${p}" ] && break
    less $p
done

popd || exit

exit 0
