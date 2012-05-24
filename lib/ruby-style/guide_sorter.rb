module RubyStyle
  class GuideSorter
    # Create a sorter on the given order.  
    #
    # guide_dir:: directory where guide YAML files live
    # order:: Array of string representing files, relative to the guide-dir, and missing their file extension.
    def initialize(guide_dir,order)
      @guide_dir = guide_dir
      @order = order
    end

    def each_in_order(&block)
      known = lambda { |a,b|
        a = clean_file(a)
        b = clean_file(b)

        ai = @order.index(a)
        bi = @order.index(b)

        ai =  1 if ai.nil?
        bi = -1 if bi.nil?

        ai <=> bi
      }
      (Dir["#{@guide_dir}/**/*.yaml"] + Dir["#{@guide_dir}/**/*.yml"]).sort(&known).each do |yaml|
        block.call(yaml)
      end
    end

  private

    def clean_file(file)
      file.gsub(@guide_dir + '/','').gsub(/\.yaml$/,'').gsub(/\.yml$/,'')
    end
  end
end
