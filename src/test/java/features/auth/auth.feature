@auth
Feature: Authentication (JWT access + refresh tokens)

  Background:
    * url baseUrl

  @smoke
  Scenario: Valid login returns tokens and the user profile
    Given path 'auth/login'
    And request { username: '#(username)', password: '#(password)', expiresInMins: 5 }
    When method post
    Then status 200
    And match response ==
      """
      {
        id: '#number',
        username: '#(username)',
        email: '#regex .+@.+',
        firstName: '#string',
        lastName: '#string',
        gender: '#string',
        image: '#string',
        accessToken: '#regex [\\w-]+\\.[\\w-]+\\.[\\w-]+',
        refreshToken: '#regex [\\w-]+\\.[\\w-]+\\.[\\w-]+'
      }
      """
    # The API also sets the tokens as cookies
    And match responseCookies contains { accessToken: '#notnull', refreshToken: '#notnull' }

  Scenario: The access token identifies the logged-in user
    * def auth = karate.callSingle('classpath:helpers/login.feature')
    Given path 'auth/me'
    And header Authorization = 'Bearer ' + auth.accessToken
    When method get
    Then status 200
    And match response.username == username

  Scenario: A refresh token yields a new working access token
    * def auth = karate.callSingle('classpath:helpers/login.feature')
    Given path 'auth/refresh'
    And request { refreshToken: '#(auth.refreshToken)', expiresInMins: 5 }
    When method post
    Then status 200
    And match response == { accessToken: '#string', refreshToken: '#string' }

    Given path 'auth/me'
    And header Authorization = 'Bearer ' + response.accessToken
    When method get
    Then status 200
    And match response.username == username

  @negative
  Scenario Outline: Login is rejected: <case>
    Given path 'auth/login'
    And request body
    When method post
    Then status 400
    And match response.message == expected

    Examples:
      | case                | body!                                       | expected                       |
      | wrong password      | { username: 'emilys', password: 'wrong' }   | Invalid credentials            |
      | unknown user        | { username: 'no_such_user', password: 'x' } | Invalid credentials            |
      | missing password    | { username: 'emilys' }                      | Username and password required |
      | non-string username | { username: 123, password: 'x' }            | Username is not valid          |

  @negative
  Scenario: Protected endpoint without a token returns 401
    Given path 'auth/me'
    When method get
    Then status 401
    And match response.message == 'Access Token is required'

  @negative
  Scenario: A malformed token is rejected
    Given path 'auth/me'
    And header Authorization = 'Bearer garbage'
    When method get
    Then status 401
    And match response.message == 'Invalid/Expired Token!'
