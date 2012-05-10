# My personal coding style

* Follow the style of the code you are editing

## Files

* One class/module per file
* Follow Rails conventions in Rails apps
* For non-Rails apps, code goes in `lib`, stdlib extensions go in `ext`
* Code for a class/module goes in the lower-cased, snake-cased named file, in a directory structure that matches the module namespaces.  For example, the class `Foo::Bar::Baz` should be in 'foo/bar/baz.rb`, relative to `lib` or `ext`
* `Test::Unit` files should go in `test` and be named `class_test.rb`, e.g. to test the class `Foo`, create `test/foo_test.rb`.  
* Nest test classes to match modules if you have a large library with a lot of different namespaces
* Follow RSpec and Cucumber file/dir naming conventions

## Formatting

* 2-space indent
* Do not bother aligning arrows, equals, or colons.  If there are so many grouped together, consider restructuring your code
* avoid single-line methods
* Keep line lengths 80 characters or less unless doing so negatively impacts readability (e.g. for large string literals)
* For "options-hash" calls, align keys across multiple lines, one per line, e.g.

```ruby
some_call(non_option1,non_option2,:foo => "bar",
                                  :blah => "quux",
                                  :bar => 42)
```
* When declaring attributes with `attr_reader` or `attr_accessor`, put one per line
* Literal lists should be on one line or one element per line, depending on length
* `protected` and `private` should be aligned with `class`

  ```ruby
  class SomeClass

    def public_method
    end

  protected

    def protected_method
    end

  private

    def private_method
    end
  end
  ```
* `protected` and `private` are surrounded by newlines
* A newline after `class` or `module`
* A newline after `end` unless it's the string of `end`s for the end of the class/module
* class methods should be defined via `def self.class_name` and not inside a `class << self`
* when using the return value of an `if` expression, indent the `else` and `end` with the `if`:

```ruby
  # Wrong
  result = if something?
    :foo
  else
    :bar
  end

  # Right
  result = if something?
              :foo
           else
              :bar
           end
```

## Naming

### Variables

* Avoid abbreviations
* Avoid one-character names
* For non "primitive" types, use the name of the class, or the name of the class plural if a collection, unless there will be multiple instances in scope, then *do not* follow this convention

  ```ruby
  customer = Customer.find(124)
  customers = Customer.find_all_by_gender("M")
  ```
* For procs and lambdas, use a verb as opposed to `proc` or something

### Methods

* Follow the "referentially transparent" naming scheme of using `foo` and `foo=` for "accessors".
* Boolean methods end in a question mark
* Dangerous methods end in a bang.  A dangerous method might be:
  * side-effects 
  * an action that cannot be undone
  * an action that might raise an exception, if there is a non-bang method that will not

### Classes & Modules

* For non-Rails apps, namespace all classes in a top-level module named for your app or library
* Class names should be comprehensible without their module namespace.  For example, `ActiveRecord::Base` is a bad name, because the class name is `Base`.
* Class names should be nouns
* Non-namespace module names should tend toward adjectives, e.g. `Enumerable`
* Namespace module names should tend toward nouns

## General Style

### Code

* Avoid 1.9-style hash syntax
* For libraries or CLI apps, stick to 1.8-compatible features where possible
* Use Jim Weirich style for blocks:
  * Blocks that return a value you intend to use should use curly braces
  * Blocks that do not return a value or a value you will ignore use `do..end`
* Always use parens unless you are coding in a heavy "DSL Style" bit of code
* Do not use `else` with an `unless`
* Do not use an `unless` for any expression that requires a `||`, `&&`, or `!`.  Either extract to a method or use `if`
* Use inline if/unless for "early-exit" features only
* Do not use inline if/unless if the expression is complex or approaches the line length
* Do not go to great lengths for a single return point; instead make the code cleaner so it's not an issue
* Do not catch `Exception` unless you *really* want to catch 'em all.
* When you must mutate an object before returning it, avoid creating intermediate objects and use `tap`:

  ```ruby
  # Wrong
  def eligible_person(name)
    person = Person.create(:name => name)
    person.update_eligibility(true)
    person.save!
    person
  end

  # Correct
  def eligible_person(name)
    Person.create(:name => name).tap { |person|
      person.update_eligibility(true)
      person.save!
    }
  end
  ```
* Feel free to chain `Enumerable` calls using simple blocks instead of one complex block that does everything.
* Avoid conditionals based on the truthiness or falsiness of a variable.  Use `.present?` or `.nil?` to be clear as to what's being tested
* If your method returns true or false, be sure those are the only values returned.

### Documentation

#### README

* There should be a README that includes:
  * What the library/app does, in one line
  * How to install your app/code
  * The most simplest example possible of using it
  * A more detailed overview, pointing to key classes or modules
  * Additional info for developing with the code

#### Classes & Modules

* Rubydoc all classes with at least the purpose of the class
* Use `#:nodoc:` on modules that are used for namespacing
* For non-namespaced modules, the Rubydoc should include the names and purpose of all methods that a class is expected to provide when mixing in

#### Methods

* Rubydoc all methods':
  * Parameter types
  * Known keys for "options hash" style
  * Default values for keys in options hash
  * Return type
* Document a method's purpose if it's name alone cannot easily communicate it
* Document the meaning of parameter types if their name alone isn't enough to communicate it
* Do not document default parameter values

#### Attributes & constants

* Rubydoc public attributes (`attr_accessor` et.al.) as to their type and purpose if the purpose isn't clear
* Rubydoc public constants

#### Inline

* Use inline comments for explain *why* something is the way it is, not *what* the code is doing

### Design

* Classes should do one thing and one thing only
* If a class has only one method, consider using a lambda or proc instead
* For a base class with abstract methods, include the methods in the base class and have them raise.  This gives you a single place to provide documentation
* Avoid instantiating classes inside other classes.  Prefer dependency injection and default parameter values.  This makes it easier to test the classes, but doesn't require Herculean efforts to instantiate classes at runtime:

  ```ruby
  class PersonFormatter
    def format(person)
      # whatever
    end
  end

  # Option 1 - constructor injection
  class View
    def initialize(person_formatter=PersonFormatter.new)
      @person_formatter = person_formatter
    end

    def render
      # code
      puts @person_formatter.format(person)
      # more code
    end
  end

  # Option 2 - setter injection with a sensible default
  class View
    attr_writer :person_formatter
    def initialize(person_formatter)
      @person_formatter = PersonFormatter.new
    end

    def render
      # code
      puts @person_formatter.format(person)
      # more code
    end
  end
  ```
* Don't make methods public unless they are part of the public interface
* `protected` is likely not correct; only use it for the template method pattern and even then, would a lambda or proc work better?
* Know the `ClassMethods` pattern for sharing class methods via a module
* Do not use ivars as a way of avoiding method parameters.
* private methods should be used to make public methods clear; they should avoid reliance on ivars if at-all possible
* private methods calling more private methods might indicate a second class is hiding inside this class

## Testing

* Unit test methods should have three parts:

  ```ruby
  def test_something
    # Given
    # set up conditions for the test

    # When
    # perform the action under test

    # Then
    # assert the correctness of the action 
  end
  ```
* For mocking, include a fourth part before "When":

  ```ruby
  def test_something
    # Given
    # set up conditions for the test

    # When the test runs, Then
    # mock expectations

    # When
    # perform the action under test

    # Then
    # assert the correctness of the action 
  end
  ```
* If your only assertion is that mock expectations are met, include that:

  ```ruby
  def test_something
    # Given
    # set up conditions for the test

    # When the test runs, Then
    # mock expectations

    # When
    # perform the action under test

    # Then mock expectations should've been met
  end
  ```
* For block-based assertions, place the code inside a lambda to preserve the structure

  ```ruby
  def test_something
    # Given
    name = 'Dave'

    # When
    code = lambda { Person.create(:name => name) }

    # Then
    assert_difference('Person',&code)
    assert_equal name,Person.last.name
  end
  ```
* Avoid literals that aren't relevant to the test; abstract into a `any` method or `some` method, e.g. `some_int`
* For literals that *are* relevant to the test, use them only once, in a variable rather than duplicate them throughout the test
* Extract setup and assertions that are the same *by design* into help methods
* Leave repeated code that is the same *by happenstance*
* The "When" part of your tests should ideally use the public API of the class under test.  Avoid constructs like `person.should be_valid` and instead favor `person.valid? should == true` or `assert person.valid?` 
* If you need to sanity-check your setup, use `raise` instead of `assert`
* Avoid fixtures, factories, or other globally-shared setup data.  Use helper modules and method extraction if data should be shared, but avoid global scope.

## Rails

### Controllers

* There should be very few `if` statements; controllers should be as dumb as possible
* avoid excessive filters, or filters that are highly conditional
* `routes.rb` should route only and exactly what your app responds to (i.e. `rake routes` should be the truth, the whole truth, and nothing but the truth)
* Prefer exposing the exact objects views require rather than "root" objects that require the view to traverse deeply-nested hierarchies
* Do not create ivars unless they are to be shared with the views.

### Views

### ActiveRecord

* Do not use hooks
* validations should not be conditional
* Use database constraints to enforce valid data in the database
* AR objects should be as dumb as possible; only derived values should be new methods
* Create classes for anything else
