@products
Feature: Product writes. DummyJSON simulates them: it returns the result but stores nothing.

  Background:
    * url baseUrl
    * def data = call read('classpath:helpers/data.js')

  @smoke
  Scenario: Add a product: 201 with the data echoed back and a new id
    * def newProduct = data.newProduct()
    Given path 'products', 'add'
    And request newProduct
    When method post
    Then status 201
    And match response contains newProduct
    And match response.id == '#number'

    # Simulated write: the new id was never saved
    Given path 'products', response.id
    When method get
    Then status 404

  Scenario: PUT and PATCH change only the fields sent
    Given path 'products', 1
    When method get
    Then status 200
    * def original = response

    Given path 'products', 1
    And request { title: 'Renamed by PUT' }
    When method put
    Then status 200
    And match response contains { id: 1, title: 'Renamed by PUT', price: '#(original.price)', category: '#(original.category)' }

    Given path 'products', 1
    And request { price: 1.5, stock: 0 }
    When method patch
    Then status 200
    And match response contains { id: 1, title: '#(original.title)', price: 1.5, stock: 0 }

  Scenario: Delete marks the product as deleted with a timestamp
    Given path 'products', 2
    When method delete
    Then status 200
    And match response contains { id: 2, isDeleted: true, deletedOn: '#regex \\d{4}-\\d{2}-\\d{2}T.+Z' }

  Scenario Outline: Add products from CSV data: <title>
    * def newProduct = data.newProduct({ title: title, price: Number(price), stock: Number(stock), category: category })
    Given path 'products', 'add'
    And request newProduct
    When method post
    Then status 201
    And match response contains { title: '#(title)', price: '#(Number(price))', stock: '#(Number(stock))', category: '#(category)' }

    Examples:
      | read('classpath:testdata/new-products.csv') |

  @negative
  Scenario: Updating a product that doesn't exist returns 404
    Given path 'products', 999999
    And request { title: 'Nope' }
    When method put
    Then status 404
    And match response.message == "Product with id '999999' not found"
