# Lab Spring Boot OpenShift

# Build Forge

```
export FORGE_SNAPSHOT=/Users/chmoulli/Code/jboss/forge/core-chris-fk
cd FORGE_SNAPSHOT; mvn clean install -DskipTests; cp dist/target/forge-distribution-3.6.2-SNAPSHOT-offline.zip ~/Temp/dev; cd ~/Temp/dev; rm -rf forge forge-distribution-3.6.2-SNAPSHOT; unzip forge-distribution-3.6.2-SNAPSHOT-offline.zip; ln -s forge-distribution-3.6.2-SNAPSHOT forge;cd -
```

# Create Project

```
./scripts/setup.sh
```
