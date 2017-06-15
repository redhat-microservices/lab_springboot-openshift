#!/usr/bin/env bash

#
# Prerequisite : Install jq --> https://stedolan.github.io/jq/download/
# brew install jq
#  ./scripts/deploy_openshift.sh <PROJECT_DIR>
# PATH of the PROJECT directory
#

PROJECT_DIR=${1:-workshop}
export CURRENT=$(pwd)

cd $PROJECT_DIR

echo "#########################################################"
echo "Add mysql ephemeral template and deploy the MySQL Server "
echo "#########################################################"
oc create -f https://raw.githubusercontent.com/openshift/origin/v1.5.1/examples/db-templates/mysql-ephemeral-template.json
oc new-app --template=mysql-ephemeral \
    -p MYSQL_USER=mysql \
    -p MYSQL_PASSWORD=mysql \
    -p MYSQL_DATABASE=catalogdb

echo "##########################################"
echo "Create missing files, deps (bootstrap.properties/service & route)"
echo "##########################################"
cd cdservice

mkdir -p src/main/config-local
mkdir -p src/main/config-openshift
cp $SCRIPTS_DIR/service/data-mysql.sql src/main/config-openshift/data.sql
mv src/main/resources/application.properties src/main/config-local
mv src/main/resources/data.sql src/main/config-local

forge -e "project-remove-dependencies com.h2database:h2:"

touch src/main/config-openshift/bootstrap.properties
cat << 'EOF' > src/main/config-openshift/bootstrap.properties
spring.application.name=cdservice
EOF

mkdir -p src/main/fabric8
touch src/main/fabric8/configmap.yml

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
      <id>local</id>\
      <dependencies>\
        <dependency>\
          <groupId>com.h2database</groupId>\
          <artifactId>h2</artifactId>\
        </dependency>\
      </dependencies>\
      <build>\
        <resources>\
          <resource>\
            <directory>src/main/config-local</directory>\
          </resource>\
          <resource>\
            <directory>src/main/resources</directory>\
          </resource>\
        </resources>\
      </build>\
    </profile>\
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

