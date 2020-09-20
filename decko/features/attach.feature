@javascript
Feature: File Upload
  I want to be able to upload files and images.

  Background:
    Given I am signed in as Joe Admin

  Scenario: Block creating a new empty file
    When I go to new File
    And I fill in "card_name" with "a test file"
    And I press "Submit"
    Then I should see "Problems with"
    And I should see "is missing"

  Scenario: Uploading a file
    When I go to new File
    And I upload the file "file.txt"
    Then I should see file "file.txt 9 Bytes"
    When I press "Delete"
    Then I should see "Add File..."
    When I upload the file "file.txt"
    And I fill in "card_name" with "a test file"
    And I press "Submit"
    Then I should see "Download a test file"

  Scenario: Uploading and changing an image
    When I go to new Image
    And I upload the image "image.png"
    Then I should see file "image.png 34.3 KB"
    And I fill in "card_name" with "a test image"
    And I press "Submit"
    Then I should see an image of size "large" and type "png"
    And I edit "a test image"
    And I upload the image "image2.jpg"
    Then I should see file "image2.jpg 69.8 KB"
    And I press "Save and Close"
    Then I should see an image of size "large" and type "jpg"

  Scenario: Changing a coded image
    When I edit "yeti skin+Image"
    And I upload the image "image2.jpg"
    Then I should see file "image2.jpg 69.8 KB"
    And I press "Save and Close"
    Then I should see a non-coded image of size "large" and type "jpg"

  Scenario: uploading a file as a field in a form
    When I go to  "/new Cardtype"
    And I fill in "card_name" with "complicated_card"
    And I press "Submit"
    And I create HTML card "complicated card+*type+*structure" with content "{{+image}}{{+description}}"
    And I go to "/new complicated_card"
    And I fill in "card_name" with "Vignesh has a complicated relationship"
    And I upload the image "image.png"
    Then I should see file "image.png 34.3 KB"
    And I press "Submit"
    Then I should see an image of size "medium" and type "png"

  Scenario: updating a file as a field in a form
    When I go to  "/new Cardtype"
    And I fill in "card_name" with "complicated_card"
    And I press "Submit"
    And I create HTML card "complicated card+*type+*structure" with content "{{+Image}}{{+description}}"
    And I go to "/new complicated_card"
    And I fill in "card_name" with "Vignesh has a complicated relationship"
    And I upload the image "image.png"
    And I should see file "image.png"
    And I press "Submit"
    And I edit "Vignesh has a complicated relationship"
    And I upload the image "image2.jpg"
    Then I should see file "image2.jpg 69.8 KB"
    And I press "Save and Close"
    Then I should see an image of size "medium" and type "jpg"

  Scenario: submit a form without updating a file
    When I go to  "/new Cardtype"
    And I fill in "card_name" with "complicated_card"
    And I press "Submit"
    And I create HTML card "complicated card+*type+*structure" with content "{{+Image}}{{+description}}"
    And I go to "/new complicated_card"
    And I fill in "card_name" with "Vignesh has a complicated relationship"
    And I upload the image "image.png"
    And I press "Submit"
    And I edit "Vignesh has a complicated relationship"
    And I press "Save and Close"
    Then I should see "+Image"
    And I should see an image of size "medium" and type "png"
