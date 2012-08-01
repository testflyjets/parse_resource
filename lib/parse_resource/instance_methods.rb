module ParseResource
  module InstanceMethods #:nodoc:
    
    def parse_file(name, attrs={})
      @_parse_files ||= {}
      @_parse_files[name] ||= ParseFile.new(name, self, attrs)
      @_parse_files[name]
    end

    def each_file
      self.class.parse_file_fields.each do |name|
        yield(name, parse_file(name))
      end
    end
    
    def save_parse_files
      each_file do |name, file|
        file.send(:save)
      end
    end
    
    def destroy_parse_files
      each_file do |name, file|
        file.send(:destroy)
      end
    end
    
  end
end