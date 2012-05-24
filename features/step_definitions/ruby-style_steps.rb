require 'yaml'

Given /^a basic guide in '(.*)'$/ do |dirname|
  @top_guide = [
    {:rule => 'some rule', :why => 'because' },
    {:rule => 'some other rule', :why => 'I said so' },
  ]
  @section_guide = [
    {:rule => 'section rule', :why => 'no reason' },
    {:rule => 'other section rule', :why => 'crucial bro', :example => 'puts foo' }
  ]
  @section_guide2 = [
    {:rule => 'section2 rule', :why => 'no reason' },
    {:rule => 'other section2 rule', :why => 'crucial bro', :example => 'puts foo' }
  ]
  FileUtils.mkdir_p dirname
  FileUtils.mkdir_p File.join(dirname,'some_section')
  
  File.open(File.join(dirname,'guide.yml'),'w') do |file|
    file.puts @top_guide.to_yaml
  end
  File.open(File.join(dirname,'some_section','foo.yml'),'w') do |file|
    file.puts @section_guide.to_yaml
  end
  File.open(File.join(dirname,'some_section','bar.yml'),'w') do |file|
    file.puts @section_guide2.to_yaml
  end
end
Then /^the stdout should include the guide in Markdown without the why$/ do
  (@top_guide + @section_guide + @section_guide2).each do |rule|
    step %{the stdout should contain "#### #{rule[:rule]}"}
    step %{the stdout should not contain "#{rule[:why]}"}
    if rule[:example]
      step %{the stdout should contain "```ruby"}
      step %{the stdout should contain "#{rule[:example]}"}
    end

  end
  step %{the stdout should contain "## Some Section"}
  step %{the stdout should contain "### Foo"}
  step %{the stdout should not contain "### Tmp"}
end

Then /^the stdout should include the guide in Markdown$/ do
  (@top_guide + @section_guide + @section_guide2).each do |rule|
    step %{the stdout should contain "#### #{rule[:rule]}"}
    step %{the stdout should contain "#{rule[:why]}"}
    if rule[:example]
      step %{the stdout should contain "```ruby"}
      step %{the stdout should contain "#{rule[:example]}"}
    end

  end
  step %{the stdout should contain "## Some Section"}
  step %{the stdout should contain "### Foo"}
  step %{the stdout should not contain "### Tmp"}
end

Then /^'(.*)' should include the guide in Markdown$/ do |filename|
  (@top_guide + @section_guide + @section_guide2).each do |rule|
    step %{the file "#{filename}" should contain "#### #{rule[:rule]}"}
    step %{the file "#{filename}" should contain "#{rule[:why]}"}
    if rule[:example]
      step %{the file "#{filename}" should contain "```ruby"}
      step %{the file "#{filename}" should contain "#{rule[:example]}"}
    end
  end
  step %{the file "#{filename}" should contain "## Some Section"}
  step %{the file "#{filename}" should contain "### Foo"}
  step %{the file "#{filename}" should not contain "### Tmp"}
end

Given /^a preamble in '(.*)'$/ do |filename|
  @custom_preamble = <<EOS
# Style Guide

#### Break these rules and DIE

You have been warned
EOS
  File.open(filename,'w') do |file|
    file.puts @custom_preamble
  end
end

Then /^the stdout should include the custom preamble$/ do
  step %{the stdout should contain "#{@custom_preamble}"}
end

Then /^the stdout should not include the standard preamble$/ do
  step %{the stdout should not contain "Ruby Style Guide"}
  step %{the stdout should not contain "#### These rules should be broken if it increase code clarity or maintainability"}
  step %{the stdout should not contain "#### First and foremost, use the style of the code you are modifying"}
end

Then /^the stdout should include the standard preamble$/ do
  step %{the stdout should contain "Ruby Style Guide"}
  step %{the stdout should contain "#### These rules should be broken if it increase code clarity or maintainability"}
  step %{the stdout should contain "#### First and foremost, use the style of the code you are modifying"}
end

