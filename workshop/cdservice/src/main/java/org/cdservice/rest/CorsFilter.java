package org.cdservice.rest;

import java.io.IOException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletResponse;
import javax.ws.rs.container.ContainerRequestContext;
import javax.ws.rs.container.ContainerResponseContext;
import javax.ws.rs.container.ContainerResponseFilter;

import org.springframework.stereotype.Component;

/**
 * @author <a href="mailto:cmoullia@redhat.com">Charles Moulliard</a>
 */
@Component
public class CorsFilter implements Filter {

	public void doFilter(ServletRequest request, ServletResponse res, FilterChain chain)
			throws IOException, ServletException {
		HttpServletResponse response = (HttpServletResponse) res;
		response.setHeader("Access-Control-Allow-Origin", "*");
		response.setHeader("Access-Control-Allow-Methods", "POST, PUT, GET, OPTIONS, DELETE");
		response.setHeader("Access-Control-Allow-Headers", "x-requested-with");
		response.setHeader("Access-Control-Max-Age", "3600");
		chain.doFilter(request, res);
	}

	public void init(FilterConfig filterConfig) {}

	public void destroy() {}

}
/*	@Override
	public void filter(ContainerRequestContext request,
			ContainerResponseContext response) {
		response.getHeaders().putSingle("Access-Control-Allow-Origin", "*");
		response.getHeaders().putSingle("Access-Control-Expose-Headers",
				"Location");
		response.getHeaders().putSingle("Access-Control-Allow-Methods",
				"GET, POST, PUT, DELETE");
		response.getHeaders()
				.putSingle("Access-Control-Allow-Headers",
						"Content-Type, User-Agent, X-Requested-With, X-Requested-By, Cache-Control");
		response.getHeaders().putSingle("Access-Control-Allow-Credentials",
				"true");
	}*/