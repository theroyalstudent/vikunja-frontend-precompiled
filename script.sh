#!/bin/bash

# ensure holding folder exists
mkdir ../data

# update the master branch
git checkout master
git remote add upstream https://github.com/go-vikunja/frontend.git
git pull upstream master

# get the hash of the updated branch
HASH=$(git rev-parse --short HEAD)
MESSAGE=$(git show -s --format=%s)
DESCRIPTION=$(git show -s --format=%b)

# check whether there is an old node-modules folder
if [[ -d ../data/vikunja-frontend-precompiled-node-modules ]]; then
	mv ../data/vikunja-frontend-precompiled-node-modules ./node_modules
fi

# run the compiler
yarn
yarn run build

# take the /dist folder, move it out
mv dist ../data/$HASH-compiled

# change branch to compiled
git checkout compiled

# move the node files to holding folder
mv ./node_modules ../data/vikunja-frontend-precompiled-node-modules

# continue with deletion
rm -rf ./*
mv ../data/$HASH-compiled/* .
rm -rf ../data/$HASH-compiled

# update with new commit
git add .
git commit -a -m "Compiled commit $HASH - $MESSAGE" -m "$DESCRIPTION"
git push origin compiled

# update origin with updated upstream content
git checkout master
git push origin master

# return to compiler branch
git checkout compiler