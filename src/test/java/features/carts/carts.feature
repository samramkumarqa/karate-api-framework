@carts
Feature: Carts: totals are calculated by the server

  Background:
    * url baseUrl
    * def cartProductSchema = read('classpath:schemas/cart-product.json')
    * def sumOf = (items, fn) => items.reduce((sum, item) => sum + fn(item), 0)

  @smoke
  Scenario: New cart totals add up line by line
    Given path 'carts', 'add'
    And request { userId: 1, products: [{ id: 1, quantity: 2 }, { id: 5, quantity: 1 }] }
    When method post
    Then status 201
    And match response contains { id: '#number', userId: 1, totalProducts: 2, totalQuantity: 3 }
    And match each response.products == cartProductSchema

    # Each line total is price x quantity, and the cart total is the sum of the lines (to the cent)
    * def lines = response.products
    And match each lines == '#? Math.abs(_.total - _.price * _.quantity) < 0.01'
    * def expectedTotal = sumOf(lines, l => l.total)
    And assert Math.abs(response.total - expectedTotal) < 0.01
    And assert response.discountedTotal <= response.total

  Scenario: Cart prices come from the catalogue
    Given path 'carts', 'add'
    And request { userId: 1, products: [{ id: 7, quantity: 1 }] }
    When method post
    Then status 201
    * def line = response.products[0]

    Given path 'products', 7
    When method get
    Then status 200
    And match line contains { id: 7, title: '#(response.title)', price: '#(response.price)' }

  Scenario: The same product added twice is merged into one line
    Given path 'carts', 'add'
    And request { userId: 1, products: [{ id: 3, quantity: 1 }, { id: 3, quantity: 2 }] }
    When method post
    Then status 201
    And match response.products == '#[1]'
    And match response.products[0] contains { id: 3, quantity: 3 }

  Scenario: A user's carts all belong to that user
    Given path 'users', 1, 'carts'
    When method get
    Then status 200
    And match each response.carts contains { userId: 1 }

  @negative
  Scenario Outline: Invalid cart is rejected: <case>
    Given path 'carts', 'add'
    And request body
    When method post
    Then status <status>
    And match response.message == message

    Examples:
      | case          | body!                                          | status | message                            |
      | unknown user  | { userId: 999999, products: [{ id: 1 }] }      | 404    | User with id '999999' not found    |
      | no user id    | { products: [{ id: 1 }] }                      | 400    | User id is required                |
      | no products   | { userId: 1, products: [] }                    | 400    | products can not be empty          |
