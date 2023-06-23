#!/bin/bash

if [[ -n $1 ]]; then
  echo "writeBuildInfo.sh - writing version $1"
  echo "instance.version=$1" > classes/BuildInfo.properties
  echo "versionDate_ddmmyyyy=$(date +%d/%m/%Y)" >> classes/BuildInfo.properties
else
  echo "writeBuildInfo.sh - no version to write, leaving BuildInfo.properties unchanged"
fi