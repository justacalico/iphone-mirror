#!/bin/sh
set -eu
VERSION="${1:?usage: bump-version.sh <version>}"
sed -i "s/^version: .*/version: ${VERSION}+1/" pubspec.yaml
