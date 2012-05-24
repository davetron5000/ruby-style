module RubyStyle
  class FileRenderer
    # Override the default rule_renderer
    attr_writer :rule_renderer

    # output: IO on which to output the rendering
    # options: control how rendering happens:
    #          +:why+:: if true, render the "why" portion
    def initialize(output,options)
      @output = output
      @root_dir = options['guide-dir']
      @rule_renderer = RuleRenderer.new(@output,options)
      @preamble = File.read(options['preamble'])
    end

    def render_preamble
      @output.puts @preamble
      @rendered_titles = {}
    end

    def render_yaml_file(filename)
      title,subtitle = split_and_titlize(filename)
      unless @rendered_titles[title]
        @output.puts "## #{title}" 
        @output.puts
      end
      if subtitle
        @output.puts "### #{subtitle}" 
        @output.puts
      end
      @rendered_titles[title] = true
      rules = YAML::load(File.open(filename))
      raise "No rules in #{filename}" if rules.nil?
      rules.each do |rule|
        @rule_renderer.render(rule)
      end
    end

  private

    def split_and_titlize(filename)
      title,subtitle = filename.gsub(/\.yaml$/,'').gsub(/\.yml$/,'').gsub(/^#{@root_dir}\//,'').split(/\//)
      [titlize(title),titlize(subtitle)]
    end

    def titlize(title)
      return nil if title.nil?
      title.split(/_/).map { |part|
        part[0..0].upcase + part[1..-1]
      }.join(" ")
    end
  end
end
