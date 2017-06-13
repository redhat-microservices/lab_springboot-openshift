#!/usr/bin/env bash

#
# Usage
# ./scripts/all.sh (when using locally minishift and default use & password admin/admin)
# ./scripts/all.sh -a https://console.35.187.106.198.nip.io:8443 -u admin -p password
# ./scripts/all.sh -a https://console.35.187.106.198.nip.io:8443 -t TOKEN
#

while getopts a::u::p::t:: option
do
        case "${option}"
        in
                a) api=${OPTARG};;
                u) user=${OPTARG};;
                p) password=${OPTARG};;
                t) token=${OPTARG};;
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

echo "############################"
echo "API : $api"
echo "User : $user"
echo "Password : $password"
echo "Token : $token"
echo "############################"

echo "Log on to OpenShift Machine"
if [ "$token" != "" ]; then
   echo "oc login $api --token=$token"
   oc login $api --token=$token
else
   echo "oc login $api -u $user -p $password"
   oc login $api -u $user -p $password
fi

echo "##########################################"
echo "## Log on to openshift - minishift, create workshop project/namespace and assign role view"
echo "##########################################"
oc login https://$(minishift ip):8443 -u admin -p admin
oc new-project workshop
oc policy add-role-to-user view -n $(oc project -q) -z default

./scripts/create_cdstore.sh demo
./scripts/deploy_on_openshift.sh

export APP=$(oc get route cdservice -o json | jq '.spec.host' | tr -d \"\")
while [ $(curl --write-out %{http_code} --silent --output /dev/null $APP/rest/catalogs) != 200 ]
   do
     echo "Wait till we get http response 200 .... from $APP/rest/catalogs"
     sleep 30
done
