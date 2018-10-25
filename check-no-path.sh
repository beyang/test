#!/bin/bash

set -euo pipefail

function usage() {
    cat <<'EOF'
Usage: ./check-no-dir.sh $rev $pathSpec

       $rev is the revision to check for the existence of the path.
       $pathSpec is the path spec passed to `git log ${rev} -- ${pathSpec}` to determine if the path exists in the history.
EOF
    exit 1
}

if [ "$#" -ne 2 ]; then
    usage
fi

rev="$1"
pathSpec="$2"

if [ ! -z "$(git log ${rev} -- ${pathSpec})" ]; then
    echo "! Path \"${pathSpec}\" exists in revision history of ${rev}" 1>&2
    exit 1
fi
