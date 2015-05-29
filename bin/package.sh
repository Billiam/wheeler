#!/bin/bash
echo "Packaging app"
mkdir -p .tmp

(cd src && zip -9 -q -r $CIRCLE_ARTIFACTS/wheeler.love .)

declare -a builds=("32" "64")

for i in "${builds[@]}"
do
  mkdir -p .tmp/love-win$i
  cp cache_dependencies/love-win$i/*.dll .tmp/love-win$i
  cp cache_dependencies/love-win$i/license.txt .tmp/love-win$i
  cat build/win/$i/love.exe $CIRCLE_ARTIFACTS/wheeler.love > .tmp/love-win$i/wheeler.exe
  (cd .tmp/love-win$i && zip -q -r $CIRCLE_ARTIFACTS/wheeler-win$i.zip .)
done