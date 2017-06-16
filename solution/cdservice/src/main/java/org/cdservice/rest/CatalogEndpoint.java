package org.cdservice.rest;

import java.util.List;

import com.netflix.hystrix.contrib.javanica.annotation.HystrixCommand;
import java.util.Collections;
import javax.persistence.EntityManager;
import javax.persistence.NoResultException;
import javax.persistence.OptimisticLockException;
import javax.persistence.PersistenceContext;
import javax.persistence.TypedQuery;
import javax.ws.rs.Consumes;
import javax.ws.rs.DELETE;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.PUT;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.Response.Status;
import javax.ws.rs.core.UriBuilder;

import org.cdservice.model.Catalog;
import org.cdservice.model.GetCatalogListCommand;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

/**
 *
 */
@Path("/catalogs")
@Component
@Transactional
public class CatalogEndpoint {

	@PersistenceContext
	private EntityManager em;

	@POST
	@Consumes("application/json")
	public Response create(Catalog entity) {
		em.persist(entity);
		return Response.created(UriBuilder.fromResource(CatalogEndpoint.class)
				.path(String.valueOf(entity.getId())).build()).build();
	}

	@DELETE
	@Path("/{id:[0-9][0-9]*}")
	public Response deleteById(@PathParam("id") Long id) {
		Catalog entity = em.find(Catalog.class, id);
		if (entity == null) {
			return Response.status(Status.NOT_FOUND).build();
		}
		em.remove(entity);
		return Response.noContent().build();
	}

	@GET
	@Path("/{id:[0-9][0-9]*}")
	@Produces("application/json") public Response findById(@PathParam("id") Long id) {
		TypedQuery<Catalog> findByIdQuery = em.createQuery(
				"SELECT DISTINCT c FROM Catalog c WHERE c.id = :entityId ORDER BY c.id",
				Catalog.class);
		findByIdQuery.setParameter("entityId", id);
		Catalog entity;
		try {
			entity = findByIdQuery.getSingleResult();
		}
		catch (NoResultException nre) {
			entity = null;
		}
		if (entity == null) {
			return Response.status(Status.NOT_FOUND).build();
		}
		return Response.ok(entity).build();
	}
	@GET
	@Produces("application/json")
	@HystrixCommand(groupKey="CatalogGroup", fallbackMethod = "getFallback")
	public List<Catalog> listAll(@QueryParam("start") Integer startPosition, @QueryParam("max") Integer maxResult) {
		List<Catalog> list = null;
        try {
			TypedQuery<Catalog> findAllQuery = em
					.createQuery("SELECT DISTINCT c FROM Catalog c ORDER BY c.id", Catalog.class);
			if (startPosition != null) {
				findAllQuery.setFirstResult(startPosition);
			}
			if (maxResult != null) {
				findAllQuery.setMaxResults(maxResult);
			}
			list = findAllQuery.getResultList();
		} catch (Exception e) {
			throw new RuntimeException("JPA issue");
		}
	    return list;
	}

/*	@GET
	@Produces("application/json")
	public List<Catalog> listAll(
			@QueryParam("start") Integer startPosition,
			@QueryParam("max") Integer maxResult) {
		return new GetCatalogListCommand(em, startPosition, maxResult).execute();
	}*/

	@HystrixCommand
	public List<Catalog> getFallback(Integer StartPosition, Integer maxResult) {
		Catalog catalog = new Catalog();
		catalog.setArtist("Fallback");
		catalog.setTitle("Circuit breaker is open as the DB is down !");
		return Collections.singletonList(catalog);
	}

	@PUT
	@Path("/{id:[0-9][0-9]*}")
	@Consumes("application/json")
	public Response update(
			@PathParam("id") Long id, Catalog entity) {
		if (entity == null) {
			return Response.status(Status.BAD_REQUEST).build();
		}
		if (id == null) {
			return Response.status(Status.BAD_REQUEST).build();
		}
		if (!id.equals(entity.getId())) {
			return Response.status(Status.CONFLICT).entity(entity).build();
		}
		if (em.find(Catalog.class, id) == null) {
			return Response.status(Status.NOT_FOUND).build();
		}
		try {
			entity = em.merge(entity);
		}
		catch (OptimisticLockException e) {
			return Response.status(Response.Status.CONFLICT).entity(e.getEntity())
					.build();
		}

		return Response.noContent().build();
	}
}
