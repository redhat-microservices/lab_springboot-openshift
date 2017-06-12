#!/usr/bin/env bash

#
# Prerequisite : Install jq --> https://stedolan.github.io/jq/download/
# brew install jq
#  ./scripts/deploy_openshift.sh <PROJECT_DIR>
# PATH of the PROJECT directory
#

PROJECT_DIR=${1:-demo}
export CURRENT=$(pwd)

cd $PROJECT_DIR

echo "##########################################"
echo "## Log on to openshift - minishift, create workshop project/namespace and assign role view"
echo "##########################################"
oc login https://$(minishift ip):8443 -u admin -p admin
oc new-project workshop
oc policy add-role-to-user view -n $(oc project -q) -z default

echo "##########################################"
echo "Deploy the MySQL Server"
echo "##########################################"
oc new-app --template=mysql-persistent \
    -p MYSQL_USER=mysql \
    -p MYSQL_PASSWORD=mysql \
    -p MYSQL_DATABASE=catalogdb

echo "##########################################"
echo "Create missing files, deps (bootstrap.properties/service & route"
echo "##########################################"
cd cdservice

mkdir -p src/main/config-openshift
cp ../../scripts/service/data-mysql.sql src/main/config-openshift/data.sql

touch src/main/config-openshift/bootstrap.properties
cat << 'EOF' > src/main/config-openshift/bootstrap.properties
spring.application.name=cdservice
EOF

mkdir -p src/main/fabric8
touch src/main/fabric8/configmap.yml

forge -e "project-remove-dependencies com.h2database:h2:"
forge -e "project-add-dependencies org.springframework.cloud:spring-cloud-starter-kubernetes-config:0.2.0.BUILD-SNAPSHOT"

cat << 'EOF' > src/main/fabric8/configmap.yml
metadata:
  name: ${project.artifactId}
data:
  application.properties: |-
    cxf.jaxrs.component-scan=true
    cxf.path=/rest

    spring.datasource.url=jdbc\:mysql\://mysql\:3306/catalogdb
    spring.datasource.username=mysql
    spring.datasource.password=mysql

    spring.jpa.properties.hibernate.transaction.flush_before_completion=true
    spring.jpa.properties.hibernate.show_sql=true
    spring.jpa.properties.hibernate.format_sql=true
    spring.jpa.properties.hibernate.hbm2ddl.auto=create-drop
    spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MySQLDialect
EOF

touch src/main/fabric8/route.yml
cat << 'EOF' > src/main/fabric8/route.yml
apiVersion: v1
kind: Route
metadata:
  name: ${project.artifactId}
spec:
  port:
    targetPort: 8080
  to:
    kind: Service
    name: ${project.artifactId}
EOF

xml="<profiles>\
    <profile>\
      <id>openshift</id>\
      <dependencies>\
        <dependency>\
          <groupId>mysql</groupId>\
          <artifactId>mysql-connector-java</artifactId>\
        </dependency>\
      </dependencies>\
      <build>\
        <resources>\
          <resource>\
            <directory>src/main/config-openshift</directory>\
          </resource>\
          <resource>\
            <directory>src/main/resources</directory>\
          </resource>\
        </resources>\
      </build>\
    </profile>\
  </profiles>\
</project>"

sed -i.bak "s|</project>|$xml|" pom.xml

echo "##########################################"
echo "Install cdservice "
echo "##########################################"
mvn clean compile fabric8:deploy -Popenshift -DskipTests=true

sleep 1m

cd ../cdfront
APP=$(oc get route cdservice -o json | jq '.spec.host' | tr -d \"\")
echo "{ \"cd-service\": \"http://$APP/rest/catalogs/\" }" > src/main/resources/static/service.json

mkdir -p src/main/fabric8/
touch src/main/fabric8/svc.yml

cat << 'EOF' > src/main/fabric8/svc.yml
apiVersion: v1
kind: Service
metadata:
  name: ${project.artifactId}
spec:
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8081
  type: ClusterIP
EOF

touch src/main/fabric8/route.yml

cat << 'EOF' > src/main/fabric8/route.yml
apiVersion: v1
kind: Route
metadata:
  name: ${project.artifactId}
spec:
  port:
    targetPort: 8081
  to:
    kind: Service
    name: ${project.artifactId}
EOF

echo "##########################################"
echo "Install cdfront "
echo "##########################################"
mvn fabric8:deploy

cd $CURRENT

