#!/bin/bash
set -e

TAG=$(git tag --points-at `git rev-list --no-merges -n 1 $CIRCLE_SHA1`)
# If current commit is tagged
if [ -n "$TAG" ]; then
  export GITHUB_REPO=wheeler
  export GITHUB_USER=Billiam

  # Abort if release already exists
  cache_dependencies/github-release info -t $TAG && exit 1 || true

  # Create release
  cache_dependencies/github-release release \
    --tag $TAG \
    --name $TAG

  declare -a release_files=("wheeler.love" "wheeler-win32.zip" "wheeler-win64.zip")

  for i in "${release_files[@]}"
  do
    cache_dependencies/github-release upload \
      --tag $TAG \
      --name $i \
      --file $CIRCLE_ARTIFACTS/$i
  done
fi