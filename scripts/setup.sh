#!/usr/bin/env bash

#
# Usage: ./scripts/setup.sh <PROJECT_DIR> <FORGE_PATH>
# E.g. ./scripts/setup.sh demo ~/Temp/dev/forge/bin
#

PROJECT_DIR=${1:-demo}
FORGE_PATH=$2

export CURRENT=$(pwd)
export FORGE_PATH=$2

if [ -d $PROJECT_DIR ]; then
 echo "Deleting $PROJECT_DIR directory ...."
 rm -rf $PROJECT_DIR
fi

echo "##############################################"
echo "## Create Maven Parent POM under $PROJECT_DIR"
echo "##############################################"
mvn archetype:generate -DarchetypeGroupId=org.codehaus.mojo.archetypes -DarchetypeArtifactId=pom-root -DarchetypeVersion=RELEASE -DinteractiveMode=false -DgroupId=org.cdstore -DartifactId=project -Dversion=1.0.0-SNAPSHOT
mv project $PROJECT_DIR && cd $PROJECT_DIR

echo "##############################################"
echo "## Run Forge commands to create the project"
echo "##############################################"
$FORGE_PATH/forge -e "run ../scripts/cdstore-forge.fsh"

cd $CURRENT

