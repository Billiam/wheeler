#!/bin/bash

mkdir -p cache_dependencies
mkdir -p .tmp

declare -a builds=("32" "64")

for i in "${builds[@]}"
do
  if [ ! -d "cache_dependencies/love-win$i" ]; then
    wget -qO .tmp/love-win$i.zip https://bitbucket.org/rude/love/downloads/love-0.9.2-win$i.zip
    unzip .tmp/love-win$i.zip -d cache_dependencies/
    mv cache_dependencies/love-0.9.2-win$i cache_dependencies/love-win$i
  fi
done

if [ ! -f cache_dependencies/github-release ]; then
  wget -qO .tmp/github-release.tar.bz2 https://github.com/aktau/github-release/releases/download/v0.5.3/linux-amd64-github-release.tar.bz2
  tar xjf .tmp/github-release.tar.bz2 -C .tmp
  mv .tmp/bin/linux/amd64/github-release cache_dependencies
fi
# wget -qO .tmp/love-macosx-x64.zip https://bitbucket.org/rude/love/downloads/love-0.9.2-macosx-x64.zip