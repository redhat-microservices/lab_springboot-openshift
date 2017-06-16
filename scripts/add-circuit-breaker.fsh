# Add dependencies
project-add-dependencies org.springframework.cloud:spring-cloud-starter-hystrix:1.2.7.RELEASE
project-add-dependencies org.springframework.boot:spring-boot-starter-actuator:

# Add EnableCircuitBreaker annotation on DemoApplication
java-add-annotation --annotation org.springframework.cloud.client.circuitbreaker.EnableCircuitBreaker --target-class org.cdservice.DemoApplication
