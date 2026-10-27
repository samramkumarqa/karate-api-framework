@ignore
Feature: Log in and return tokens
  # Used via karate.callSingle(...): runs once per test run, and every feature shares the cached result.

  Scenario: login
    Given url baseUrl
    And path 'auth/login'
    And request { username: '#(username)', password: '#(password)', expiresInMins: 30 }
    When method post
    Then status 200
    * def accessToken = response.accessToken
    * def refreshToken = response.refreshToken
