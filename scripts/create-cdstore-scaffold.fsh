# ------  CD Store Web Front End [:8081/rest] ---------------
project-new --named cdfront --type spring-boot --create-static-content=true --port 8081

# Come up to parent project
cd ..

# Create the CD Service project
# ----------------  CD Service [:8080/rest] ---------------
project-new --named cdservice --type spring-boot

# Setup JPA connection with H2 in memory DB
jpa-setup

# create Catalog entity and add fields
jpa-new-entity --named Catalog
jpa-new-field --named artist --target-entity org.cdservice.model.Catalog
jpa-new-field --named title --target-entity org.cdservice.model.Catalog
jpa-new-field --named description --length 2000 --target-entity org.cdservice.model.Catalog
jpa-new-field --named price --type java.lang.Float --target-entity org.cdservice.model.Catalog
jpa-new-field --named publication_date --type java.util.Date --temporalType DATE --target-entity org.cdservice.model.Catalog

# Create REST endpoints
rest-generate-endpoints-from-entities --targets org.cdservice.model.* --generator SPRING_BOOT_JPA_ENTITY

# Enable CORS
rest-new-cross-origin-resource-sharing-filter

# Scaffold code
scaffold-setup --provider AngularJS
scaffold-generate --provider AngularJS --generate-rest-resources --targets org.cdservice.model.*

# Come up to top level so we can create a new project
cd ~~
cd ..