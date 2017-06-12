#!/usr/bin/env bash

#
# Usage: ./scripts/setup.sh <PROJECT_DIR> <SCAFFOLD_BOOLEAN>
# E.g.
# To scaffold, simply add the true boolean
# ./scripts/setup.sh demo true
#
# By default, nos scaffolding will take place
# ./scripts/setup.sh demo
#
# You can also use another JBoss Forge path
# FORGE_HOME=$HOME/.forge ./scripts/setup.sh demo
#

PROJECT_DIR=${1:-demo}
SCAFFOLD=${2:-false}
export CURRENT=$(pwd)

if [ -d $PROJECT_DIR ]; then
 echo "## Deleting $PROJECT_DIR directory ...."
 rm -rf $PROJECT_DIR
fi

echo "##############################################"
echo "## Create Maven Parent POM under $PROJECT_DIR"
echo "##############################################"
mvn archetype:generate -DarchetypeGroupId=org.codehaus.mojo.archetypes -DarchetypeArtifactId=pom-root -DarchetypeVersion=RELEASE -DinteractiveMode=false -DgroupId=org.cdstore -DartifactId=project -Dversion=1.0.0-SNAPSHOT
mv project $PROJECT_DIR && cd $PROJECT_DIR

if [ $SCAFFOLD = true ]; then
    echo "##############################################"
    echo "## Run Forge commands to create the project & Scaffold"
    echo "##############################################"
    exec forge -e "run ../scripts/create-cdstore-scaffold.fsh"
  else
    echo "##############################################"
    echo "## Run Forge commands to create the project "
    echo "##############################################"
    exec forge -e "run ../scripts/create-cdstore.fsh"
fi

echo "##############################################"
echo "## Copy static content & SQL data for h2"
echo "##############################################"
cp -r ../scripts/service/data-h2.sql cdservice/src/main/resources/data.sql

if [ $SCAFFOLD = true ]; then
   mv cdservice/src/main/webapp/* cdfront/src/main/resources/static/
 else
   cp -r ../scripts/front/modified/ cdfront/src/main/resources/static/
fi

echo "####################################################"
echo "## Compile project to check if everything works !!!"
echo "####################################################"
# mvn clean install

cd $CURRENT

