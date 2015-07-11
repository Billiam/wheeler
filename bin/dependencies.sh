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

# wget -qO .tmp/love-macosx-x64.zip https://bitbucket.org/rude/love/downloads/love-0.9.2-macosx-x64.zip

cp ~/.aws/credentials ~/.s3cfg
sed -i 's/^aws_access_key_id/access_key/g; s/aws_secret_access_key/secret_key/g' ~/.s3cfg

