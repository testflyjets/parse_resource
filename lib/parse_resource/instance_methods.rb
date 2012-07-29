module ParseResource
  module InstanceMethods #:nodoc:
    def parse_file(name, attrs={})
      @_parse_files ||= {}
      @_parse_files[name] = ParseFile.new(name, self, attrs)
      @_parse_files[name]
    end
    
    def parse_files
      @_parse_files
    end

    def each_file
      parse_files.each do |name, file|
        yield(name, file)
      end
    end
    
    def save_parse_files
      each_file do |name, file|
        file.send(:save)
      end
    end
    
    def destroy_parse_files
      each_file do |name, file|
        file.send(:flush_deletes)
      end
    end
    
    # def prepare_for_destroy
    #   each_attachment do |name, attachment|
    #     attachment.send(:queue_all_for_delete)
    #   end
    # end
  end
end