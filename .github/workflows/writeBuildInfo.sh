#!/bin/bash

echo "version=$1" > classes/BuildInfo.properties
echo "versionDate_ddmmyyyy=$(date +%d/%m/%Y)" >> classes/BuildInfo.properties
