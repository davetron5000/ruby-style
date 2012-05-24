module RubyStyle
  class RuleRenderer
    # options: control how rendering happens:
    #          +:why+:: if true, render the "why" portion
    def initialize(output,options)
      @show_why = options[:why]
      @output = output
    end

    # rule:: hash containing:
    #        +:rule+:: text of the rule (required)
    #        +:why+:: explanation for why the rule exists
    #        +:example+:: example showing the rule in use
    def render(rule)
      @output.puts "#### #{rule[:rule]}"
      @output.puts
      if @show_why
        @output.puts "Why? _#{rule[:why]}_" if rule[:why]
        @output.puts
      end
      unless String(rule[:example]).strip == ''
        @output.puts "```ruby"
        @output.puts rule[:example]
        @output.puts "```"
      end
      @output.puts
    end
  end
end

