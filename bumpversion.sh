#!/bin/sh

COMMIT_MSG=$(dart run pub_version_plus:main patch)

git add --all
git commit -m $COMMIT_MSG
