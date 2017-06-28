#!/usr/bin/env bash

export ENDPOINT=http://cdservice-workshop.$(minishift ip).nip.io
for i in `seq 1 1500`
do
    curl $ENDPOINT/rest/catalogs >/dev/null 2>/dev/null

    if (( $i % 5 == 0 ))
    then
        echo -n "."
    fi

    if (( $i % 250 == 0 ))
    then
        echo " "
    fi

    if (( $i == 250 ))
    then
        echo "Bring DB down"
        oc scale --replicas=0 dc mysql
    else
        if (( $i == 500 ))
        then
            echo "Restore DB"
            oc scale --replicas=1 dc mysql
        fi
    fi
done
echo " "