@users
Feature: Users

  Background:
    * url baseUrl

  Scenario: The logged-in user's profile matches their public record
    * def auth = karate.callSingle('classpath:helpers/login.feature')
    Given path 'auth', 'me'
    And header Authorization = 'Bearer ' + auth.accessToken
    When method get
    Then status 200
    * def me = response

    Given path 'users', me.id
    When method get
    Then status 200
    And match response contains { id: '#(me.id)', username: '#(me.username)', email: '#(me.email)' }

  Scenario: Filter users by a field
    Given path 'users', 'filter'
    And params { key: 'gender', value: 'female', limit: 0 }
    When method get
    Then status 200
    And match response.users == '#[_ > 0]'
    And match each response.users contains { gender: 'female' }
