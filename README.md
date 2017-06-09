# Lab Spring Boot OpenShift

# Build Forge & Spring Boot addon

```
export FORGE_SNAPSHOT=/Users/chmoulli/Code/jboss/forge/core-chris-fk
cd $FORGE_SNAPSHOT; mvn clean install -DskipTests; rm -rf ~/Temp/dev/*; cp dist/target/forge-distribution-3.6.2-SNAPSHOT-offline.zip ~/Temp/dev; cd ~/Temp/dev; unzip forge-distribution-3.6.2-SNAPSHOT-offline.zip; ln -s forge-distribution-3.6.2-SNAPSHOT forge;cd -

cd /Users/chmoulli/Code/spring/springboot-addon-chris-fk
git pull
mvn clean install -DskipTests=true

export FORGE_PATH=~/Temp/dev/forge/bin
$FORGE_PATH/forge -i org.jboss.forge.addon:spring-boot,1.0.0-SNAPSHOT
$FORGE_PATH/forge -r org.jboss.forge.addon:spring-boot,1.0.0-SNAPSHOT
```

# Create Project

```
FORGE_PATH=~/Temp/dev/forge/bin ./scripts/setup.sh demo
```
