project-new --named cdservice --type spring-boot --dependencies web jpa h2 actuator
jpa-setup --db-type H2 --data-source-name java:jboss/datasources/CatalogDS
jpa-new-entity --named Catalog
jpa-new-field --named artist --target-entity org.cdservice.model.Catalog
jpa-new-field --named title --target-entity org.cdservice.model.Catalog
jpa-new-field --named description --length 2000 --target-entity org.cdservice.model.Catalog
jpa-new-field --named price --type java.lang.Float --target-entity org.cdservice.model.Catalog
jpa-new-field --named publicationDate --type java.util.Date --temporalType DATE --target-entity org.cdservice.model.Catalog

rest-generate-endpoints-from-entities --targets org.cdservice.model.*
