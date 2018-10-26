#!/usr/bin/env bash
#
# From the git docs for pre-push:
#
# Information about what is to be pushed is provided on the hook’s standard input with lines of the form:
#
# <local ref> SP <local sha1> SP <remote ref> SP <remote sha1> LF
# For instance, if the command git push origin master:foreign were run the hook would receive a line
# like the following:
#
# refs/heads/master 67890 refs/heads/foreign 12345
#
# although the full, 40-character SHA-1s would be supplied. If the foreign ref does not yet exist
# the <remote SHA-1> will be 40 0. If a ref is to be deleted, the <local ref> will be supplied as
# (delete) and the <local SHA-1> will be 40 0. If the local commit was specified by something other
# than a name which could be expanded (such as HEAD~, or a SHA-1) it will be supplied as it was
# originally given.


# function currentLocal() {
#     if [ -z "$GIT_PARAMS" ]; then
#         return HEAD
#     fi
# }

# function currentRemote() {
# }



echo "HERE $GIT_STDIN"
echo "### $*"

# while read local_ref local_sha remote_ref remote_sha
# do
#     echo "############ $local_ref $local_sha $remote_ref $remote_sha"
# done

echo "### HUSKY_GIT_STDIN: $HUSKY_GIT_STDIN"

function currentRemote() {
    currentBranch="$(git rev-parse --abbrev-ref HEAD)"
    if [ -z "$currentBranch" ]; then
        return 0
    fi
    currentRemote="$(git config --get branch.${currentBranch}.remote)"
    git config --get "remote.${currentRemote}.url"
}

remoteUrl="${2:-$(currentRemote)}"  # if this is invoked as a pre-push hook, the remote URL is the second argument


echo "remoteUrl was $remoteUrl"
echo "GIT_PARAMS: $GIT_PARAMS"
echo "GIT_PARAMS: $HUSKY_GIT_PARAMS"



set -e -o pipefail

case $remoteUrl in
    *"sourcegraph/sourcegraph"*)
        # If pushing to *sourcegraph/sourcegraph*, continue with check
        ;;
    *)
        # If not pushing to *sourcegraph/sourcegraph*, don't check
        exit 0
esac

function failCheck() {
    cat <<EOF
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!! DANGER: There is an enterprise/ directory and you are attempting !!
!!         to push to the open-source upstream OR committing to a   !!
!!         branch tracking the open-source upstream.                !!
!!                                                                  !!
!! Either push this change to the enterprise upstream or modify the !!
!! commits to remove the enterprise/ directory                      !!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
EOF
    exit 1
}

if [ ! -z "$(git log -- :/enterprise)" ]; then
    failCheck
fi
