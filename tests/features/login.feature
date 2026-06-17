Feature: Form authentication
As a user
I want to authenticate
So that I can access the secure area

Background:
Given the login page is open

Scenario: Successful authentication
When the user enters username "tomsmith"
And the user enters password "SuperSecretPassword!"
And the user submits the login form
Then the secure area should be displayed
And a successful login message should be visible

Scenario Outline: Authentication is rejected for invalid data
When the user enters username "<username>"
And the user enters password "<password>"
And the user submits the login form
Then the message "<message>" should be displayed


Examples:
  | username     | password             | message                    |
  | unknown-user | SuperSecretPassword! | Your username is invalid!  |
  | tomsmith     | wrong-password        | Your password is invalid!  |
  |              |                       | Your username is invalid!  |

