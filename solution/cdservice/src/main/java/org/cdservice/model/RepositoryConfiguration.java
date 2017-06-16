package org.cdservice.model;

import org.springframework.context.annotation.Configuration;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.transaction.annotation.EnableTransactionManagement;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.cloud.netflix.hystrix.EnableHystrix;

@EnableHystrix
@Configuration
@EnableAutoConfiguration
@EnableTransactionManagement
@EntityScan(basePackages = "org.cdservice.model")
@EnableJpaRepositories(basePackages = "org.cdservice.model")
public class RepositoryConfiguration {
}