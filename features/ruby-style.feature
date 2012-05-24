Feature: Generate my awesome style guide
  In order to have a fancy styleguide
  that looks good, but has content stored in a structured way
  I want to run a command-line tool on some YAML files


  Scenario: Basic UI
    When I get help for "guide"
    Then the exit status should be 0
    And the banner should be present
    And the banner should document that this app takes options
    And the following options should be documented:
      |--version    |
      |--guide-dir  |
      |--order-file |
      |--preamble   |
    And the banner should document that this app's arguments are:
      |output_file|which is optional|

  Scenario: Generate a style guide
    Given a basic guide in '/tmp/guide'
    When I run `guide --guide-dir=/tmp/guide`
    Then the stdout should include the guide in Markdown
    And the stdout should include the standard preamble

  Scenario: Generate a style guide without the "whys"
    Given a basic guide in '/tmp/guide'
    When I run `guide --guide-dir=/tmp/guide --no-why`
    Then the stdout should include the guide in Markdown without the why
    And the stdout should include the standard preamble

  Scenario: Generate a style guide with custom preamble
    Given a basic guide in '/tmp/guide'
    And a preamble in '/tmp/preamble.md'
    When I run `guide --guide-dir=/tmp/guide --preamble=/tmp/preamble.md`
    Then the stdout should include the guide in Markdown
    And the stdout should include the custom preamble
    But the stdout should not include the standard preamble

  Scenario: Generate a style guide to a file
    Given a basic guide in '/tmp/guide'
    When I run `guide --guide-dir=/tmp/guide /tmp/guide.md`
    Then '/tmp/guide.md' should include the guide in Markdown
