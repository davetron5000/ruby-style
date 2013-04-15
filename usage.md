# Style Guide

This is my style guide.  There are many like it, but this one is mine.

If you like the guide in principle, but disagree with some of the rules, I really don't want to know about it, but you should feel free to tweak it for you or your team. To do that:

1. Clone this repo
2. `bundle install`
3. Tweak files in `guide` and `etc`
4. `bin/guide README.md`
5. Push to github
6. (optional) Use Github's fancy-pants site generator to make it pretty.

That's it!

It reads from the files in `guide` and `etc` to generate the guide.  Any `.yml` or `.yaml` file in `guide` will get picked up.  The ordering will be somewhat random, so the file `etc/order.yaml` is used to control the order in which files are rendered.
It should be pretty obvious what the format is.

So, you can easily add your own, tweak what's there, etc.

## Format of the YAML

Each YAML file is an array of rules.  Each rule is a Hash with three parts:

* `:rule` - the text of the rule, e.g. "Use 2-space indent".  This is required.
* `:why` - a brief explanation of why the rule exists.  This can be omitted
* `:example` - a multi-line code-block of some example code demonstrating the rule.

### Example:

Here are three rules.  The first has only a rule, the second adds a "why" and the third has an exmaple.

```yaml
- :rule: "Keep line lengths 80 characters or less unless doing so negatively impacts readability (e.g. for large string literals)"
- :rule: "Literal arrays or hashes should have a comma after *every* element, includingn the last one"
  :why: "This makes it easier to add elements and reorder elements without having to worry about missing commas"
- :rule: "For 'options-hash' calls, align keys across multiple lines, one per line, e.g."
  :why: "This makes it easier to read and modify the options sent to the method"
  :example: |
    some_call(non_option1,non_option2,:foo => "bar",
                                      :blah => "quux",
                                      :bar => 42)
```

## Customizations

    $ bin/guide --help
    Usage: guide [options] [output_file]

    Generate your style guide in markdown based on YAML files

    v0.0.1

    Options:
            --version                    Show help/version info
            --guide-dir DIR              Dir to find your guide files
                                         (default: guide)
            --[no-]why                   Include 'why' in the guide
            --order-file FILE            File that orders the guide elements
                                         (default: bin/../etc/order.yaml)
            --preamble FILE              File containing Markdown preamble
                                         (default: bin/../etc/preamble.md)

This pretty much covers it; you can generate files from other directories, customize the order file, omit the "Why", and make your own preamble.

### Tool Tweaks

While I don't want to incorporate your particular style, I very much *do* what to incorporate any bugfixes or features to the tool itself.  It's pretty hard-coded to Markdown and a particular way of doing things that I think looks decent on Github, but
feel free to make all that better or more flexible!

    $ rake features

will guide the way
