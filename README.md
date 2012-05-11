## Active Record

#### Do not use hooks

Why? _Hooks make your models very hard to use in different ways, and lock them to business rules that are likely not all that hard and fast.  They also make testing very difficult, as it becomes harder and harder to set up the correct state using objects that have excessive hooks on them._

```ruby
# Wrong, we've hidden business logic behind a simple CRUD operation
class Person < ActiveRecord::Base
  after_save :update_facebook

private

  def update_facebook
    # send Facebook some status update 
  end
end

# Better, we have a method that says what it does
class Person < ActiveRecord::Base

  def save_and_update_facebook
    if save
      # Send Facebook some status update
    end
  end
end
```

#### Validations should not be conditional

Why? _Validations that are not always applicable make it very hard to modify objects and enhance them, because it becomes increasingly difficult tor understand what a valid objects really is.  Further, it becomes very difficult to set up objects in a particular state for a given test if there are a lot of conditonal validations_


#### Use database constraints to enforce valid data in the database

Why? _The database is the only place that can truly ensure various constraints, such as uniqueness.  Constraints are incredibly useful for making sure that, regardless of bugs in your code, your data will be clean._


#### AR objects should be as dumb as possible; only derived values should be new methods

Why? _It may be tempting to add business logic to your models.  This instanvce violates the single responsiblity principal, but it also makes the classes harder and harder to understand, test, and modify.  Treat your modesl as dumb structs with persistence, and put all other concerns on other classes.  Do not just mix in a bunch of modules._


## Controllers

#### There should be very few `if` statements; controllers should be as dumb as possible

Why? _`if` statements usually imply business logic, which does not belong in controllers.  The logic in the controller should be mainly concerned with send the correct response to the user._


#### Avoid excessive filters, or filters that are highly conditional

Why? _When the number of filters increases, it becomes harder and harder to know what code is executing and in what order.  Further, when filters set instance variables, it becomes increasingly difficult to understand where those variables are being set, and the filters become very order-specific.  Finally, conditional filters, or filters used on only one controller method increase complexity beyond the point of utility_


#### `rake routes` should be the truth, the whole truth, and nothing but the truth

Why? _By lazily creating all routes for a resource, when you only need a few to be valid, you create misleading output for newcomers, and allow valid named route methods to be created that can only fail at runtime or in production._

```ruby
# Wrong, our app only supports create and show
resources :transactions

# Right, rake routes reflects the reality of our app now
resources :transactions, :only => [:create, :show]
```

#### Prefer exposing the exact objects views require rather than 'root' objects requiring deep traveral

Why? _When views navigate deep into object hierarchies, it becomes very difficult to understand what data the views really *do* require, and it makes refactoring anything in those object hierarchies incredibly difficult_

```ruby
# A view for a person's credit cards requires the person's name, and a list of last-4, type, and expiration date of cards

# Wrong, the view must navigate through the person to get his credit cards and has
# access to the entire person objects, which is not needed
def show
  @person = Person.find(params[:person_id])
end

# Wrong, although the view can now access credit cards directly, it's still not clear what data
# is really needed by the view
def show
  @person = Person.find(params[:person_id])
  @credit_cards = @person.credit_cards
end

# Right, the ivars represent what the view needs AND contain only what the view needs.
# You may wish to use a more sophisticated "presenter" pattern instead of OpenStruct
def show
  @person_name = Person.find(params[:person_id].full_name
  @credit_cards = @person.credit_cards.map { |card|
    OpenStruct.new(:last_four => card.last_four, 
                   :card_type => card.card_type,
                   :expiration_date => [card.expiration_month,card.expiration_year].join('/'))
  }
end
```

#### Do not create ivars unless they are to be shared with the views.

Why? _Using instance variables to avoid passing parameters is lazy and creates complex and hard-to-understand code.  In a controller, instance variables are special: they represent the data passed to the views, and that's all they should be used for._


## Design

#### Classes should do one thing and one thing only



#### If a class has only one method, consider using a lambda or proc instead

Why? _A class with one method, especially Doer.do, is just a function, so make it a lambda_


#### For a base class with abstract methods, include the methods in the base class and have them raise.

Why? _This gives you a single place to document the methods subclasses are expected to implement, and ensures that, at least at runtime, they *are* implemented_


#### Avoid instantiating classes inside other classes.  Prefer dependency injection and default parameter values.

Why? _This makes it easier to test the classes, but doesn't require Herculean efforts to instantiate classes at runtime:_

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

#### Don't make methods public unless they are part of the public interface

Why? _Public is the way to formally document the contract of your class.  Putting methods that shouldn't be called by others in the public interface is just lazy, and increases maintenance down the road._


#### `protected` is likely not correct; only use it for the template method pattern and even then, would a lambda or proc work better?

Why? _Protected is used to allow subclasses to call non-public methods.  This implies a potentially complex type hierarchy, which is likely not correct for what you are doing._


#### Know the `ClassMethods` pattern for sharing class methods via a module

Why? _It's a convienient pattern to add macro-style methods to classes_

```ruby
module Helper
  def self.included(k)
    k.extend ClassMethods
  end
  module ClassMethods
    def strategy(strat)
      @strategy = strat
    end
  end
end

class UsesHelper
  include Helper

  strategy :foo

  def doit; puts self.strat; end
end
```

#### Do not use ivars as a way of avoiding method parameters.

Why? _Intance variables are a form of global data, and your routines' complexity increases when their input comes from multiple sources.  If the instance variables control flow or logic, pass them in as parameters_


#### private methods should be used to make public methods clear; they should avoid reliance on ivars if at-all possible

Why? _Private methods that do not rely on instance variables can very easily be extracted to new classes when things get compledx_


#### private methods calling more private methods might indicate a second class is hiding inside this class



## Documentation

### Classes And Modules

#### Rubydoc all classes with at least the purpose of the class

Why? _Naming is hard; documentation helps explain what a class is for_


#### For non-namespaced modules, the Rubydoc should include the names and purpose of all methods that a class is expected to provide when mixing in

Why? _Because we don't have types, the user of your module needs to know what methods to implement to make the module work_


#### Summarize the purpose of the class or module as the first line

Why? _This lets someone see, at a glance, what the construct is for_


#### Do not start documentation with 'This class' or 'This module'

Why? _We know what kind of thing it is; just state what it does_


### General

#### Use RDoc instead of YARD or TomDoc

Why? _RDoc.info does not support TomDoc, and YARD is way too heavyweight_


#### Do not surround class or method names in your project with code blocks

Why? _RDoc will link to methods or classes in your project_


#### DO surround class or method names from other libraries with code blocks

Why? _This makes it clear that you mean a method name or class, because RDoc cannot link outside of your codebase_


#### Reserve inline comments for answering 'Why?' questions

Why? _Don't restate what the code does, but DO explain why it works the way it does, especially if it does something in a suprising or weird way, from a business logic perspective_

```ruby
## Wrong, don't explain what the code does, we can read it
def minor?
  # Check if they are under 19
  self.age < 19
end

## Right, explain the odd logic so others know it is intentional, with
## a ref for more info as to why
def minor?
  # For our purposes, an 18-year-old is still a minor.  See
  # ticket XYZ for a more detailed discussion
  self.age < 19
end
```

### Methods

#### Rubydoc the parameter types and return types

Why? _There's no other way to tell what the types are and it's just not nice to hide this info_


#### Document all known keys, their types, and their default values for 'options hash' style params

Why? _Because it's jerky not to; there's no other way to know what they are_

```ruby
# Makes a request
#
# url:: url to request
# options:: options to control request:
#           +:method+:: HTTP method to use as a String (default "GET")
#           +:content_type+:: Mime type to include as a header, as a String (default "text/plain")
#           +:if_modified_since+:: Date for if-modified-since header, default nil
def request(url,options={})
end
```

#### Document a method's purpose if it's name alone cannot easily communicate it

Why? _Good method names are preferred, but if it's somewhat complex, add a bit more about what the method does_


#### Document the meaning of parameter types if their name alone isn't enough to communicate it

Why? _Again, the parameter names should be meaninful, but if they don't full explain things, throws us a bone_


#### Do not document default parameter values

Why? _These valuers show up in rdoc, so restating them is just a maintenance issue_


#### Document the types of each attribute created with an `attr_` method

Why? _No other way to know what the types are_


### Readme

#### There should be a README that includes:

Why? _Because a README is a nice way to explain what your code is/does_


#### The README should explain what the library/app does, in one line

Why? _Summarizing things in one line is helpful_


#### The README should explain how to install your app/code

Why? _Because not everyone knows what needs to be done, even if it's just `gem install`_


#### The README should show the simplest example possible of using the library/ap

Why? _This, along with the description allows someone to understand your library/app in under a minute_


#### A more detailed overview, pointing to key classes or modules

Why? _When rendered as RDoc, these classes link to where the user should start reading to get a deeper perspective_


#### Additional info for developing with the code

Why? _If you want contributions, developers need to know how to work with your code_


## Files

#### One class/module per file

Why? _Makes it simpler to locate and organize code_


#### Follow Rails conventions in Rails apps



#### For non-Rails apps, code goes in `lib`, stdlib extensions go in `ext`

Why? _This is where most Rubyists will expect it, and clearly delineates _your app_ from lib extensions_


#### Code for a class/module goes in the lower-cased, snake-cased named file, in a directory structure that matches the module namespaces.  For example, the class `Foo::Bar::Baz` should be in `foo/bar/baz.rb`, relative to `lib` or `ext`

Why? _Makes it simpler to locate the code for a given class_


#### `Test::Unit` files should go in `test` and be named `class_test.rb`, e.g. to test the class `Foo`, create `test/foo_test.rb`.  

Why? _Test dir is then sorted by classname, making it easy to visually scan or auto-complete test names_


#### Nest test classes to match modules if you have a large library with a lot of different namespaces



#### Follow RSpec and Cucumber file/dir naming conventions



## Formatting

#### 2-space indent

Why? _this is standard across almost all Ruby code_


#### Do not bother aligning arrows, equals, or colons.  If there are so many grouped together, consider restructuring your code

Why? _Alignment requires extra work to maintain, and results in hard-to-understand diffs when alignment must change_


#### Avoid single-line methods

Why? _Single-line methods are harder to change when the method needs an additional line_


#### Keep line lengths 80 characters or less unless doing so negatively impacts readability (e.g. for large string literals)

Why? _Excessively long lines can be very difficult to read and understand; a low line length encourages keeping things simple_


#### For 'options-hash' calls, align keys across multiple lines, one per line, e.g.

Why? _This makes it easier to read and modify the options sent to the method_

```ruby
some_call(non_option1,non_option2,:foo => "bar",
                                  :blah => "quux",
                                  :bar => 42)
```

#### When declaring attributes with `attr_reader` or `attr_accessor`, put one per line

Why? _This makes it easier to add new attributres without creating complex diffs.  It also affords documenting what the attributes represent_

```ruby
# wrong, hard to modify
attr_accessor :first_name, :last_name, :gender

# correct, we can easily modify and document
attr_accessor :first_name
attr_accessor :last_name
attr_accessor :gender
```

#### Literal lists should be on one line or one element per line, depending on length

Why? _Two-dimensional data is hard to read and modify._


#### `protected` and `private` should be aligned with `class`

Why? _No reason, just my personal preference_

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

#### `protected` and `private` are surrounded by newlines

Why? _Visually sets them off_


#### A newline after `class` or `module`

Why? _Visual clearance_


#### A newline after `end` unless it's the string of `end`s for the end of the class/module

Why? _I don't get much value from visual clearance for the end blocks that 'close' a class or module_


#### class methods should be defined via `def self.class_name` and not inside a `class << self`

Why? _This reduces errors caused by moving methods around, and also doesn't require you to scroll up in the class to determine what type of method it is; you can see it instantly_


#### when using the return value of an `if` expression, indent the `else` and `end` with the `if`:

Why? _This makes it very clear that you are using `if..else..end` as a complex expression and not as a control structure_

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

## General Style

#### Avoid 1.9-style hash syntax

Why? _This syntax only works if your hash keys are symbols; otherwise you have to use the old syntax.  There's a very limited benefit to the new syntax, and the cost is two ways of doing things, increasing mental overhead when reading/writing code.  Further, for libraries, 1.8 compatibility is nice to achieve_


#### For libraries or CLI apps, stick to 1.8-compatible features where possible

Why? _Many shops are still on 1.8, and many systems have 1.8 as the default, so there's no reason not to keep 1.8 compatible for code that will be shared_


#### Blocks that return a value you intend to use should use curly braces

Why? _This visually sets them off, and makes for a cleaner chaning syntax_

```ruby
# Wrong, calling a method on 'end' is awkward looking
male_teens = Customers.all.select do |customer|
  customer.gender == :male 
end.reject do |man|
  man.age > 19 || man.age < 13
end

# Right, the chaining and use of the comprehensions is clear
male_teens = Customers.all.select { |customer|
  customer.gender == :male 
}.reject { |man|
  man.age > 19 || man.age < 13
}
```

#### Blocks that do not return a value or a value you will ignore use `do..end`

Why? _These blocks are more control-structures, so `do..end` is more natural.  It sets them off from blocks that produce a useful value_


#### Always use parens when calling methods with arguments unless you are coding in a heavy 'DSL Style' bit of code

Why? _Parens visually set off the parameters, and reduce confusion about how Ruby will parse the line, making the code easier to maintain_


#### Do not use `else` with an `unless`

Why? _the expression becomes too difficult to unwind, just use an `if`_


#### Do not use an `unless` for any expression that requires a `||`, `&&`, or `!`.  Either extract to a method or use `if`

Why? _`unless` is like putting a giant `!()` around your expression, so it becomes harder and harder to understand what is being tested by adding this.  It's not worth it_

```ruby
# Wrong, too hard to figure out
unless person.valid? && !person.from('US')
  # doit
end

# Right, DeMorgan's law simplified this
if !person.valid? || person.from('US')
  # doit
end

# Better, use a method
unless valid_and_foreign?(person)
  # doit
end
```

#### Use inline if/unless for 'early-exit' features only

Why? _Code can become hard to read when conditions are trailing and complex.  Early-exit conditions are generally simple and can benefit from this form_

```ruby
# Wrong, too complex
person.save unless person.from('US') || person.age > 18

# OK, an early exit
raise "person may not be nil" if person.nil?
```

#### Do not catch `Exception` unless you *really* want to catch 'em all.

Why? _`Exception` is the base of *all* exceptions, and you typically don't want to catch memory exceptions and the like.  Catch `StandardError` instead_


#### When you must mutate an object before returning it, avoid creating intermediate objects and use `tap`:

Why? _Intermediate objects increase the mental requirements for understanding a routine.  `tap` also creates a nice scope in which the object is being mutated; you will not forget to return the object when you change the code later_

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

#### Feel free to chain `Enumerable` calls using simple blocks instead of one complex block that does everything.

Why? _The braces syntax encourages clean chaning, and with simple blocks, you can easily follow step-by-step what is being done without having to have a bunch of private methods explaining things._


#### Avoid conditionals based on the truthiness or falsiness of a variable.  Use `.present?` or `.nil?` to be clear as to what's being tested

Why? _It's a lot clearer when you state exactly what you are testing; this makes it easier to change the code later, and avoids sticky issues like 0 and the empty string being truthy_

```ruby
# Wrong, intent is masked
if person.name
  # do it
end
# Right, we can see just what we're testing
if person.name.present?
  # do it
end
```

#### If your method returns true or false, be sure those are the only values returned.

Why? _Returning a 'truthy' value will lead to unintended consequences, and could lead to complex dependencies in your code.  You don't need the hassle_


## Naming

### Classes And Modules

#### For non-Rails apps, namespace all classes in a top-level module named for your app or library

Why? _Prevents naming clases when your code is used with other libraries_


#### Class names should be comprehensible without their module namespace.

Why? _Ensures that classnames are understood everywhere used._

```ruby
# Bad, 'Base' is not an accurate classname
class ActiveRecord::Base
end

# Good, using the class witihout its namespaced module doesn't
# remove any clarity
class Gateway::BraintreeGateway
end
```

#### Class names should be nouns

Why? _Classes represent things, and things are nouns_


#### Non-namespace module names should tend toward adjectives, e.g. `Enumerable`

Why? _Modules used as mixins represent a trait or aspect that you want to use to enhance a class.  These are naturally adjectives._


#### Namespace module names should tend toward nouns

Why? _Using modules just for namespacing is, again, specifying things, which are nouns_


### Methods

#### Follow the 'referentially transparent' naming scheme of using `foo` and `foo=` for 'accessors'.

Why? _Since Ruby allows the '=' form, using 'get' or 'set' in the names just adds noise_


#### Boolean methods end in a question mark

Why? _This allows methods that can used in expressions to clearly stand out and makes code more fluent_


#### Dangerous methods end in a bang.

Why? _This calls out methods whose use should be carefully understood_

```ruby
# Mutates the object; dangerous on an otherwise immutable object
def process!
  @processed = true
end

# Has a side-effect that is not obvious and might not
# be idempotent
def render!(output)
  queue_event(:some_event)
  output.puts @content
end

# Raises an exception on failure, unlike its analog, save, which does not
def save!
  raise ValidationException unless self.save
end
```

### Variables

#### Avoid abbreviations

Why? _Abbreviations can clash, require explanation and generally disrupt the flow of things_


#### Avoid one-character names

Why? _No reason not to be descriptive_


#### For non 'primitive' types, use the name of the class, or the name of the class plural if a collection, unless there will be multiple instances in scope, then *do not* follow this convention

Why? _When there's no particular specific name for something, using its type makes it easy to remember what the object is_

```ruby
# Just use the classname
def routine
  customer = Customer.find(124)
  customers = Customer.find_all_by_gender("M")
end

# Here we have two lists, so neither should just be "customers"
def other_routine
  males = Customer.find_all_by_gender("M")
  minors = Customer.where('age < ?',18)
end
```

#### For procs and lambdas, use a verb as opposed to `proc` or something

Why? _Procs and lambdas are more like methods and thus should be verbs, since they do something_

```ruby
# Wrong, the variable has been needlessly "nounified" for no real benefit
saver = lambda { |x| x.save! }

# Correct, the variable, being a verb, is instantly recognizable
#          as a lambda
save = lambda { |x| x.save! }
```

## Testing

#### Unit test methods should have three parts: Given, When, Then

Why? _This makes it clear what each section of the test is doing, which is crucial when tests get complex_

```ruby
def test_something
  # Given
  person = Person.new("Dave",38)

  # When
  minor = person.minor?

  # Then
  assert minor,"Expected #{person.inspect} to be a minor"
end
```

#### For mocking, include a fourth part before 'When' so that the flow of the test is maintained

Why? _It's important to established what the mock expectations are, and thinking of it as seperate from a given helps the test read better._

```ruby
def test_something
  # Given
  person = Person.new("Dave",38)

  # When the test runs, Then
  AuditStats.expects(:query).returns(true)

  # When
  minor = person.minor?

  # Then
  assert minor,"Expected #{person.inspect} to be a minor"
end
```

#### If your only assertion is that mock expectations are met, include a comment indicating this

Why? _It's important to let others know your intent that the mock expectations ARE the test and that you just didn't forget an assert_

```ruby
def test_something
  # Given
  person = Person.new("Dave",38)

  # When the test runs, Then
  PersonDAO.expects(:save).with(person)

  # When
  person.save!

  # Then mock expectations should've been met
end
```

#### For block-based assertions, place the code inside a lambda to preserve the structure

Why? _Again, this preserves the flow of the test_

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

#### Avoid literals that aren't relevant to the test; abstract into a `any` method or `some` method, e.g. `some_int`

Why? _Tests littered with literals can be very hard to follow; if the only literals in the test are those specific to *this* test, it becomes very clear what's being tested._


#### For literals that *are* relevant to the test, do not repeat them in a test

Why? _Just like magic strings are bad in real code, they are in test code.  Plus it codifies that the values are the same by design and not just by happenstance_


#### Extract setup and assertions that are the same *by design* into helper methods

Why? _If you are running a different test under the exact same conditions as another test, extract that duplicative code into a helper.  Similarly, if you are conducting a different test that should have the same outcome, extract those assertions to a helper._


#### Leave repeated code that is the same *by happenstance*

Why? _This sort of duplication is OK becauser they code is only the same by happenstance, and may diverge as the code matures.  By leaving it seperate, it's easier to change_


#### The 'When' part of your tests should ideally use the public API of the class under test.

Why? _Some RSpec constructs assert things about the class under test without calling its public API, e.g. `person.should be_valid`.  This goes against the spirit of TDD, and requires the reader to make a mental transaction between the testing DSL and the class' method, with no discernable benefit._


#### If you need to sanity-check your setup in the 'Given', use `raise` instead of `assert`

Why? _`raise` will mark your test as erroneous, not failed, as that is the case when the setup conditions for the test aren't correct.  Better yet, don't use brittle globally-shared test fixtures or factories._


#### Avoid fixtures, factories, or other globally-shared setup data.

Why? _As an app matures, the fixtures or factories become incredibly brittle and hard to modify or understand.  It also places key elements of your test setup far away from the test itself, making it hard to understand any given test._


