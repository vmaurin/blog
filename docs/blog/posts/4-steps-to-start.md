---
date: 2018-12-02
categories:
  - Practices
---

# 4 Steps to properly start a software project

As Software Engineers, we are all dealing with legacy projects. Sometimes we face a big ball of mud, sometimes we have to deal with an outdated framework spread everywhere. These situations are usually resulting from mistakes made early in a project’s life. It is important to avoid the common ones not to create a new piece of technical debt. I will give you four simple steps that will help you avoid these common pitfalls when starting a project and ensure its proper growth.

## Step 1 : Create a version control repository

Using a version control system is essential. Here is my advice:

* create a repository before you do anything else, so you will have a complete history of the project development (and not a big initial commit).
* write concise and meaningful commit messages (some guidelines [here](https://chris.beams.io/posts/git-commit/)), so your history is kept clean. Taking the time to explain the purpose of your changes in the commit message also makes you write better code.

Plenty of free solutions are out there, like [GitHub](https://github.com/) or [Gitlab](https://about.gitlab.com/), so setting up for a repository should not take long.

_Time invested: a few minutes to start a project, a few minutes for each commit messages_

## Step 2 : Set up a CI pipeline

Before writing the code, set up a continuous integration pipeline. It should be really simple at first and then grow more complex alongside code. A good initial pipeline could look like this:

* code check/compilation
* tests
* packaging
* deployment

Having a CI/CD pipeline set up from the beginning brings many advantages with little investment:

* automating and self-documenting maintenance of the project, reducing development time and human errors
* enforcing policies (tests, coding guidelines and conventions, …), making your project more readable and less prone to bugs

Again, free tools are available ([Circle CI](https://circleci.com/), [Travis CI](https://travis-ci.org/), [Gitlab CI](https://about.gitlab.com/product/continuous-integration/), …) and easy to set up.

_Time invested: a few hours_

## Step 3 : Write your business rules

This is the most important, but usually unconsidered step. People tend to start with choosing a framework, libraries, a database, a web server, etc.
Those are hard decisions to get right at this stage, and you will probably end up making some wrong choices that will be difficult to fix later. You should delay these decisions as far as possible (see Step 4).

Instead, start with writing your business rules.

Business rules come from the business specifications of your MVP. They could be described as:

* the _entities_ that are the core of your business (they exist outside automation)
* the _use cases_, that are automated operations playing with the entities

This terminology comes from [Uncle Bob’s Clean Architecture](https://www.amazon.com/Clean-Architecture-Craftsmans-Software-Structure/dp/0134494164) book.

You should be able to write all these rules without any code or software dependencies. If you use a tool like Maven to compile and build your component, it simply means that dependencies section is empty. Try to be as pure as possible, using the language and the basic SDK only.
By doing so, you will probably end up having some of the following abstractions:

* you need persistence?  
  Create an abstract interface for your persistence with adequate methods
* you need to do a service call?  
  Create an abstract interface and few data structures representing the service call
* you need to offer a service over the wire?  
  Create an abstract interface, data structures and an implementation representing this service

For testing the code, just implement these interfaces with simple and dummy in-memory objects.

This approach will result in multiple benefits:

* it is easy to test, you don’t need an advanced mock library or set up complex test environments
* it will help you identify business details and corner cases and make you ask questions to stakeholders
* it will be easier to architecture the code

_Time invested : days to a few weeks_

## Step 4 : Implement the abstraction

Before you can actually deploy functional software, you need to implement your abstractions. Having the interfaces used by your business rules should make the job easier. Maybe you don’t need a relational database after all. Maybe you can start running your service on a small HTTP server. Even if you realize you made the wrong decisions, having such boundaries will make them easier to fix.

You should also ensure that the implementations are not polluting the business rules. It is usually better to enforce that by splitting your code in different compilation units (for example, with Maven, you could have a project split in two modules, one without dependencies for business rules, the other for abstraction implementations).

_Time invested: a few days_

## Final words

Using these steps should start you out on the right path and you can reuse them for future evolutions. Think always first in term of business rules, code them and then take care of abstraction implementations. It will make your code and your projects clean, maintainable and easier to evolve.