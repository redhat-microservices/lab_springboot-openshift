package org.cdservice.model;

//import com.netflix.hystrix.HystrixCommand;
//import com.netflix.hystrix.HystrixCommandGroupKey;
import javax.persistence.EntityManager;
import javax.persistence.TypedQuery;
import java.util.Collections;
import java.util.List;
import org.cdservice.model.Catalog;

public class GetCatalogListCommand {
    private final EntityManager em;
    private final Integer startPosition;
    private final Integer maxResult;

    public GetCatalogListCommand(EntityManager em, Integer startPosition, Integer maxResult) {
        // super(HystrixCommandGroupKey.Factory.asKey("CatalogGroup"));
        this.em = em;
        this.startPosition = startPosition;
        this.maxResult = maxResult;
    }

    public List<Catalog> run() {
        TypedQuery<Catalog> findAllQuery = em
                .createQuery("SELECT DISTINCT c FROM Catalog c ORDER BY c.id", Catalog.class);
        if (startPosition != null) {
            findAllQuery.setFirstResult(startPosition);
        }
        if (maxResult != null) {
            findAllQuery.setMaxResults(maxResult);
        }
        return findAllQuery.getResultList();
    }

    public List<Catalog> getFallback() {
        Catalog catalog = new Catalog();
        catalog.setArtist("Fallback");
        catalog.setTitle("Circuit breaker is open as the DB is down !");
        return Collections.singletonList(catalog);
    }
}
