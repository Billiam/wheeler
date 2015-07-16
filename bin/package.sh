#!/bin/bash
set -e

echo "Packaging app"
mkdir -p .tmp

VERSION=`head -n 1 VERSION`

(cd src && zip -9 -q -r $CIRCLE_ARTIFACTS/app.love .)
mkdir -p .tmp/love-win32
cp cache_dependencies/love-win32/*.dll .tmp/love-win32
cp cache_dependencies/love-win32/license.txt .tmp/love-win32
cp build/readme.txt .tmp/love-win32
cat build/win/32/love.exe $CIRCLE_ARTIFACTS/app.love > .tmp/love-win32/wheeler.exe
(cd .tmp/love-win32 && zip -q -r $CIRCLE_ARTIFACTS/wheeler-win32.zip .)

#cp $CIRCLE_ARTIFACTS/app.love launcher/cache.zip
#sed -e "s;%NAME%;$APP_NAME;g" -e "s;%URL%;$APP_VERSION_URL;g" launcher/launcher_config.skel > launcher/launcher_config.lua
#rm launcher/launcher_config.skel
#(cd launcher && zip -9 -q -r $CIRCLE_ARTIFACTS/launcher.love .)
#sed -e "s;%VERSION%;$VERSION;g" -e "s;%APP_URL%;$APP_URL;g" app_version.skel > $CIRCLE_ARTIFACTS/VERSION

#declare -a builds=("32" "64")

#for i in "${builds[@]}"
#do
#  mkdir -p .tmp/love-win$i
#  cp cache_dependencies/love-win$i/*.dll .tmp/love-win$i
#  cp cache_dependencies/love-win$i/license.txt .tmp/love-win$i
#  cp build/win/luajit-request/*.dll .tmp/love-win$i
#  cat build/win/$i/love.exe $CIRCLE_ARTIFACTS/launcher.love > .tmp/love-win$i/wheeler.exe
#  (cd .tmp/love-win$i && zip -q -r $CIRCLE_ARTIFACTS/wheeler-win$i.zip .)
#done
