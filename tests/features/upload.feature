Feature: File upload

  As a user
  I want to upload a file
  So that the system can receive it

  Scenario: Successful text file upload
    Given the file upload page is open
    When the user selects "sample-upload.txt"
    And the user clicks the upload button
    Then the page should display "File Uploaded!"
    And the uploaded filename should be "sample-upload.txt"

  Scenario: Upload submission without a selected file
    Given the file upload page is open
    When the user clicks the upload button without selecting a file
    Then the system should display a validation error
    And the system should not return an internal server error