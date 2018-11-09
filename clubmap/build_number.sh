#!/bin/bash
export GIT_VERSION=$(git describe --abbrev=4 --dirty --always --tags)
export GIT_DATE=$(git --no-pager show --date=short --format="%ad" --name-only | head -n 1)
echo "#define GIT_VERSION \"$GIT_VERSION\"" > $1/build_number.h
echo "#define GIT_DATE \"$GIT_DATE\"" >> $1/build_number.h
