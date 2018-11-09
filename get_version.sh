#!/bin/bash
CURDIR=$(pwd)
SCRIPTDIR=$(dirname "$BASH_SOURCE")

cd $SCRIPTDIR
echo '**********'
echo '********** VERSION FILE PREPARE'
echo '**********'
echo $(git describe --abbrev=4 --dirty --always --tags | sed -E 's/(\.[0-9]+)\-/\1\./') > version
echo 'Version ----> '$(cat version)
cd $CURDIR
