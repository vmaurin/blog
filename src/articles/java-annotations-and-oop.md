# Java annotations and OOP

Annotations has been introduced in JDK 1.5 in order to put metadata along with the code. These metadata are available at compile time, or at runtime through reflection.

The purpose of this article is to see different use cases of annotations and how they fit regarding OOP principles.

## The core ones

The package `java.lang` provides a set of basic annotations
* `Deprecated`
* `FunctionalInterface`
* `Override`
* `SafeVarargs`
* `SuppressWarnings`

They have all the same goal : give additional information about the code to programmers and eventually run compilation checks.
They have no effect nor implication with OOP. A class or method with or without these annotations will have the same run-time behavior.

## Dependency inversion inverted

Dependency injection tools usually use annotations.

The Java EE ones :
* `Inject`
* `Singleton`
* `Resource`
* `Named`
* …

Or custom ones :
* `Autowired`
* …

These annotations clearly break principles/good practices with OOP :
* Coupling : the code of an object becomes coupled to the dependency injection annotations
* Encapsulation : when injection is applied to the private state of the object, it is exposing this inner state to an external components

Here a small example of dependency inversion in plain Java

```java
public interface DataLayer {
    Object readData(int id);
}
  
public class SqlLayer implements DataLayer {
    @Override
    public Object readData(int id) {
        // Do the job
    }
}
  
public class Service {
    private final DataLayer dataLayer;
 
    public Service(DataLayer dataLayer) {
        this.dataLayer = dataLayer;
    }
}
 
 
// Use a SqlLayer as singleton
DataLayer dataLayer = new SqlLayer();
Service serviceA = new Service(dataLayer);
Service serviceB = new Service(dataLayer);
 
// ... or use multiple one
Service serviceA = new Service(new SqlLayer());
Service serviceB = new Service(new SqlLayer());
```


By doing manually the injection, we can see that the code is totally decoupled. The `Service` or `SqlLayer` classes are totally decoupled to the way there are instantiated and injected.

Now a similar code with `javax.inject` annotations

```java
public interface DataLayer {
    Object readData(int id);
}
 
@Singleton
public class SqlLayer implements DataLayer {
    @Override
    public Object readData(int id) {
        // Do the job
    }
}
 
 
public class Service {
    @Inject
    private DataLayer dataLayer;
}
 
Service serviceA = injector.getInstance(...);
Service serviceB = injector.getInstance(...);
```

With this annotation the decision of being a singleton is delegated to the `SqlLayer` object. But then why the `SqlLayer` class need to decide how it will be instantiated ? What if we want two different `SqlLayer` objects for integration tests ?

For the `Service` class, it is even worse as the "private" field will get accessed by an external system. We can still use the annotation on a constructor to avoid this issue, but then, why we have to annotate the constructor with `Inject` at all ? The DI tool should be able to find the constructor without having to change the original object code.

## Swiss army knife data structure

One of the main motivation for introducing the annotations in Java in the first place was to provide metadata for library like :
* Xml/Json serializations
* ORM/Entity mapping with data storage
* Bean code generation

All these usage apply not to objects but to data structures, and try to reduce the amount of code required to perform a task on these data structures.

Using data structures is a useful programming technique (usually come along "procedural programming") that makes easier to add new functionalities on top of a fixed structure, while OOP makes easier to add new classes without changing the functionalities.

The purpose of annotations here is to configure the functionalities running on top of the structure. It doesn't break this principle as we are not modifying the structure itself. The only concern is a little bit of code pollution and compilation dependencies :
* you cannot compile the data structure without the functionality library. So for example, I will have to embed a Json library in my jar, even if I never use the serialization functionality in my code
* you could end up having business logic data structure having package dependencies to both data layer implementation and view serialization implementation

So, some extra care need to be taken here. Depending on the scope of a data structure, it could be better to externalize a functionality (like writing "Serializer/Deserializer" classes)

## Behavioral annotations

In specification like JAX-RS or in framework like Spring, annotations are also used to attach a behavior to an object.
There are plenty of design patterns in classical OOP to end up with the same result. Mostly, the annotations are used as an alternative syntax, to try to be more concise, but usually with the cost of less maintainability and a mixing responsibility/concern.

Here an example of annotation way to define REST API

```java
@Path("/api")
public class UserApi {
  
    @GET
    @Path("/user")
    @Produces(MediaType.APPLICATION_JSON)
    public User getUser() {
        // ...
    }
 
    @POST
    @Path("/user")
    @Consumes(MediaType.APPLICATION_JSON)
    public void createUser(User track) {
        // ...
    }
}
```

And here without annotations

```java
public class UserApiImpl implements UserApi {
    public User getUser() {
        // ...
    }
 
 
    public void createUser(User track) {
        // ...
    }
}
  
// Initialization code
UserApi api = ...;
...
// Http routing code
router.get("/api/user").produces("application/json").handler(api::getUser);
router.post("/api/user").consumes("application/json").handler(api::createUser);
```

The second solution also clearly split the responsibility of routing from the business logic. It allows you to test on the HTTP routing with a mocked api implementation or binding multiple routes or even protocols to the same logic method.