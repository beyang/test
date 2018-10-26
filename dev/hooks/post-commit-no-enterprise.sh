#!/bin/bash

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

function currentRemote() {
    currentBranch="$(git rev-parse --abbrev-ref HEAD)"
    if [ -z "$currentBranch" ]; then
        return 0
    fi
    currentRemote="$(git config --get branch.${currentBranch}.remote)"
    git config --get "remote.${currentRemote}.url"
}

remote_url="$(currentRemote)" local_sha="$(git rev-parse HEAD)" ./dev/hooks/check-no-enterprise.sh
