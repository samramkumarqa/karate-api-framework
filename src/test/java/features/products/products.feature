@products
Feature: Products catalogue: listing, paging, sorting, search and contract

  Background:
    * url baseUrl
    * def productSchema = read('classpath:schemas/product.json')
    * def reviewSchema = read('classpath:schemas/review.json')

  @smoke
  Scenario: Default list is the first page of 30 products, each matching the schema
    Given path 'products'
    When method get
    Then status 200
    And match response == { products: '#[30]', total: '#number? _ >= 30', skip: 0, limit: 30 }
    And match each response.products == productSchema
    And match each response.products[0].reviews == reviewSchema

  Scenario: Paging with limit and skip
    Given path 'products'
    And params { limit: 10, skip: 10 }
    When method get
    Then status 200
    And match response.products == '#[10]'
    And match response contains { skip: 10, limit: 10 }
    And match response.products[0].id == 11

  Scenario: select returns only the requested fields (plus id)
    Given path 'products'
    And params { limit: 5, select: 'title,price' }
    When method get
    Then status 200
    And match each response.products == { id: '#number', title: '#string', price: '#number' }

  Scenario Outline: Sort by <field> <order>
    Given path 'products'
    And params { sortBy: '<field>', order: '<order>', limit: 0 }
    When method get
    Then status 200
    * def values = karate.map(response.products, p => p['<field>'])
    * def expected = karate.sort(values, v => '<order>' == 'desc' ? -v : v)
    And match values == expected

    Examples:
      | field  | order |
      | price  | asc   |
      | price  | desc  |
      | rating | desc  |
      | stock  | asc   |

  Scenario: Server-side delay is reflected in the response time
    # DummyJSON can delay any response (?delay=ms), handy for testing timeouts and slow paths
    Given path 'products', 1
    And param delay = 1500
    When method get
    Then status 200
    And assert responseTime >= 1500

  Scenario: Search matches title or description, case-insensitively
    Given path 'products', 'search'
    And param q = 'PHONE'
    When method get
    Then status 200
    And match response.total == '#? _ > 0'
    * def mentionsPhone = p => (p.title + ' ' + p.description).toLowerCase().includes('phone')
    And match each response.products == '#? mentionsPhone(_)'

  Scenario: Search with no matches returns an empty page, not an error
    Given path 'products', 'search'
    And param q = 'zzqx-no-such-product'
    When method get
    Then status 200
    And match response == { products: [], total: 0, skip: 0, limit: 0 }

  Scenario: Every product in a category belongs to it, and categories are listed
    Given path 'products', 'category-list'
    When method get
    Then status 200
    And match response == '#[_ > 0] #string'
    And match response contains 'smartphones'

    Given path 'products', 'category', 'smartphones'
    And param limit = 0
    When method get
    Then status 200
    And match response.products == '#[_ > 0]'
    And match each response.products contains { category: 'smartphones' }
    And match response.total == karate.sizeOf(response.products)

  @negative
  Scenario Outline: Invalid request: <case>
    Given path 'products'
    And params query
    When method get
    Then status 400
    And match response.message == message

    Examples:
      | case                | query!                              | message                                            |
      | negative limit      | { limit: -1 }                       | Invalid 'limit' - should be a positive number      |
      | non-numeric skip    | { skip: 'abc' }                     | Invalid 'skip' - should be a positive number       |
      | invalid sort order  | { sortBy: 'price', order: 'up' }    | Invalid 'order' - should be either 'asc' or 'desc' |

  @negative
  Scenario: Unknown product id returns 404 with a clear message
    Given path 'products', 0
    When method get
    Then status 404
    And match response == { message: "Product with id '0' not found" }
