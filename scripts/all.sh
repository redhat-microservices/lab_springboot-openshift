#!/usr/bin/env bash

#
# Usage
# ./scripts/all.sh (when using locally minishift and default use & password admin/admin)
# ./scripts/all.sh -a https://console.35.187.106.198.nip.io:8443 -u admin -p password
# ./scripts/all.sh -a https://console.35.187.106.198.nip.io:8443 -t TOKEN
#

while getopts a:t:u:p: option
do
        case "${option}"
        in
                a) api=${OPTARG};;
                t) token=${OPTARG};;
                u) user=${OPTARG};;
                p) password=${OPTARG};;
        esac
done

api=${1:-$(minishift console --url)}
user=${2:-admin}
password=${3:-admin}

echo "Log on to OpenShift Machine"
if [ "$token" != "" ]; then
   echo "oc login https://$api --token=$token"
   oc login https://$api --token=$token
else
   echo "oc login $api -u $user -p $password"
   oc login $api -u $user -p $password
fi

oc delete project/workshop

./scripts/create_cdstore.sh demo
./scripts/deploy_on_openshift.sh

export APP=$(oc get route cdservice -o json | jq '.spec.host' | tr -d \"\")
while [ $(curl --write-out %{http_code} --silent --output /dev/null $APP/rest/catalogs) != 200 ]
   do
     echo "Wait till we get http response 200 .... from $APP/rest/catalogs"
     sleep 30
done
