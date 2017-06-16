#!/usr/bin/env bash

#
# Usage. We assume that the project/namespace 'workshop' doesn't yet exist under your user account before to run the script
#
# ./scripts/all.sh (when using locally minishift and default user & password admin/admin, directory name is workshop)
# ./scripts/all.sh -a https://console.35.187.106.198.nip.io:8443 -u admin -p password
# ./scripts/all.sh -a https://console.35.187.106.198.nip.io:8443 -t TOKEN
# ./scripts/all.sh -a https://console.35.187.106.198.nip.io:8443 -t TOKEN -d /tmp/demo
#

while getopts a::u::p::t::d:: option
do
        case "${option}"
        in
                a) api=${OPTARG};;
                u) user=${OPTARG};;
                p) password=${OPTARG};;
                t) token=${OPTARG};;
                d) directory=${OPTARG};;
        esac
done

if [ -z "$api" ];then
  api=$(minishift console --url)
fi

if [ -z "$user" ];then
  user="admin"
fi

if [ -z "$password" ];then
  password="admin"
fi

if [ -z "$directory" ];then
  directory="workshop"
fi

# Set env var with the location of the scripts dir
export SCRIPTS_DIR=$(pwd)/scripts

echo "############################"
echo "API : $api"
echo "User : $user"
echo "Password : $password"
echo "Token : $token"
echo "Directory : $directory"
echo "############################"

echo "Log on to OpenShift Machine"
if [ "$token" != "" ]; then
   echo "oc login $api --token=$token"
   oc login $api --token=$token
else
   echo "oc login $api -u $user -p $password"
   oc login $api -u $user -p $password
fi

echo "##########################################################################"
echo "## Create workshop project and add role view to th serviceacount default. "
echo "##########################################################################"
oc new-project workshop
oc policy add-role-to-user view -n $(oc project -q) -z default

echo "##########################################################################"
echo "#### Call script to create cdservice & cdfront for local usage            "
echo "##########################################################################"
./scripts/create_cdstore.sh $directory

echo "##########################################################################"
echo "#### Call script to refactor project and deploy it on Openshift            "
echo "##########################################################################"
./scripts/deploy_on_openshift.sh $directory

echo "##########################################################################"
echo "#### Wait till we get a response from the service                         "
echo "##########################################################################"
sleep 2m

export APP=$(oc get route cdservice -o json | jq '.spec.host' | tr -d \"\")
while [ $(curl --write-out %{http_code} --silent --output /dev/null $APP/rest/catalogs) != 200 ]
   do
     echo "Wait till we get http response 200 .... from $APP/rest/catalogs"
     sleep 30
done

echo "##########################################################################"
echo "#### Activate Circuit Breaker pattern and bring down MySQL instance       "
echo "##########################################################################"
./scripts/enable_circuit_breaker.sh $directory
