package com.redhat.example.capitalator;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;

@SpringBootApplication
public class CapitalatorApplication {

	public static void main(String[] args) {
		System.exit(SpringApplication.exit(SpringApplication.run(CapitalatorApplication.class, args)));
	}

}
