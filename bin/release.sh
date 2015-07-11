#!/bin/bash
set -e

s3cmd put --acl-public --add-header=Cache-Control:no-cache --guess-mime-type $CIRCLE_ARTIFACTS/$APP_NAME s3://obs-wheeler/releases/$APP_NAME
s3cmd put --acl-public --add-header=Cache-Control:no-cache --guess-mime-type $CIRCLE_ARTIFACTS/VERSION s3://obs-wheeler/releases/VERSION
