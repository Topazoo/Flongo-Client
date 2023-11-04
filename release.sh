#!/bin/sh

./bumpversion.sh
VERSION=$(grep 'version: ' pubspec.yaml | sed 's/version: //')

git tag $VERSION
git push origin $VERSION