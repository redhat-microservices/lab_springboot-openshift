#!/usr/bin/env bash

PROJECT_DIR=${1:-workshop}
export CURRENT=$(pwd)

cd $PROJECT_DIR

echo "#########################################################"
echo " Create Hystrix dashboard pod "
echo "#########################################################"
oc create -f http://repo1.maven.org/maven2/io/fabric8/kubeflix/hystrix-dashboard/1.0.28/hystrix-dashboard-1.0.28-openshift.yml
oc expose service hystrix-dashboard --port=8080

cd cdservice

# Update project using Forge
forge -e "run $SCRIPTS_DIR/add-circuit-breaker.fsh"

cat << 'EOF' > src/main/fabric8/svc.yml
apiVersion: v1
kind: Service
metadata:
  name: ${project.artifactId}
  labels:
    hystrix.enabled: true
spec:
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080
  type: ClusterIP
EOF

cat << 'EOF' >> src/main/fabric8/configmap.yml
    management.health.db.enabled=false
    management.security.enabled=false
EOF

# Replace CatalogEndpoint by modified version
cp $SCRIPTS_DIR/service/CatalogEndpointCB.java src/main/java/org/cdservice/rest/CatalogEndpoint.java

# Redeploy cdservice
mvn fabric8:undeploy
sleep 1m
mvn clean compile fabric8:deploy -Popenshift -DskipTests=true

# Scale down the DB
# oc scale --replicas=0 dc mysql

cd $CURRENT