@mock
Feature: Testing against a Karate mock server (no network needed)
  # The mock in mocks/products-mock.feature is itself written in Karate. It's stateful, so a
  # created product can be read, listed and deleted, and it can simulate outages and slow responses.

  Background:
    * def server = karate.start('classpath:mocks/products-mock.feature')
    * url 'http://localhost:' + server.port

  Scenario: Create, read, list and delete against the stateful mock
    Given path 'products'
    And request { title: 'Mock Mug', price: 12.5 }
    When method post
    Then status 201
    And match response == { id: '#number', title: 'Mock Mug', price: 12.5 }
    * def id = response.id

    Given path 'products', id
    When method get
    Then status 200
    And match response.title == 'Mock Mug'

    Given path 'products'
    When method get
    Then status 200
    And match response == { products: '#[1]', total: 1 }

    Given path 'products', id
    When method delete
    Then status 200
    And match response.isDeleted == true

    Given path 'products', id
    When method get
    Then status 404

  Scenario: Validation errors come back as 400
    Given path 'products'
    And request { price: 1 }
    When method post
    Then status 400
    And match response.message == 'title is required'

  Scenario: A simulated outage returns 503 on any route
    Given path 'products'
    And header X-Simulate = 'outage'
    When method get
    Then status 503
    And match response == { message: 'Service Unavailable' }

  Scenario: A slow endpoint is measurably slow
    Given path 'slow'
    When method get
    Then status 200
    And assert responseTime >= 600
