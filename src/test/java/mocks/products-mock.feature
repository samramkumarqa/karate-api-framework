@ignore
Feature: Stateful product API mock (Karate mock server)
  # Started from tests with karate.start(...). Scenarios are routes; the first matching one handles the request.
  # State lives in Background variables, which run once when the server starts.

  Background:
    * def products = {}
    * def counter = { next: 1 }

  # Simulated outage for any route: send the header X-Simulate: outage
  Scenario: headerContains('X-Simulate', 'outage')
    * def responseStatus = 503
    * def response = { message: 'Service Unavailable' }

  Scenario: pathMatches('/products') && methodIs('post') && request.title == null
    * def responseStatus = 400
    * def response = { message: 'title is required' }

  Scenario: pathMatches('/products') && methodIs('post')
    * def product = karate.merge(request, { id: counter.next })
    * counter.next = counter.next + 1
    * products[product.id + ''] = product
    * def responseStatus = 201
    * def response = product

  Scenario: pathMatches('/products') && methodIs('get')
    * def all = karate.valuesOf(products)
    * def response = { products: '#(all)', total: '#(karate.sizeOf(all))' }

  Scenario: pathMatches('/products/{id}') && methodIs('get') && products[pathParams.id] != null
    * def response = products[pathParams.id]

  Scenario: pathMatches('/products/{id}') && methodIs('delete') && products[pathParams.id] != null
    * def deleted = products[pathParams.id]
    * eval delete products[pathParams.id]
    * def response = karate.merge(deleted, { isDeleted: true })

  Scenario: pathMatches('/slow')
    * def responseDelay = 600
    * def response = { ok: true }

  # Anything else
  Scenario:
    * def responseStatus = 404
    * def response = { message: 'Not found' }
