module  ParseResource
  # The ParseFile class represents a Parse.com File object
  # It provides the ability to assign an uploaded file to a ParseResource
  # instance attribute, to persist the file via the Parse REST API and then 
  # associate that file with the containing ParseResource instance attribute.
  #
  # Much of the approach taken here was borrowed liberally from PaperClip:
  #   Author:: Jon Yurek
  #   Copyright:: Copyright (c) 2008-2011 thoughtbot, inc.
  class ParseFile
    include InstanceMethods
    
    attr_reader :attr_name, :instance, :tempfile, :content_type, :file_ext, :size, :original_filename, 
                :name, :url
    
    RESTRICTED_CHARACTERS = /[&$+,\/:;=?@<>\[\]\{\}\|\\\^~%# ]/
    
    def initialize(attr_name, instance, attrs={})
      @attr_name = attr_name
      @instance  = instance
      @name = attrs['name']
      @url  = attrs['url']
      
      @dirty = false
    end
    
    # Loads the attributes of the uploaded file into this object
    def assign(file)
      return nil if file.nil?
      
      @tempfile = file.tempfile
      @original_filename = cleanup_filename(file.original_filename)
      @file_ext = File.extname(@original_filename)[1..-1] unless @original_filename.blank?
      @content_type = file.content_type.to_s.strip
      @size = File.size(@tempfile.path)
      self
    end
    
    # returns Parse attributes 
    def to_parse_attr
      { '__type' => 'File', 'name' => @name, 'url' => @url }
    end
    
    def dirty?
      @dirty
    end
    
    # Saves the file and then updates or creates the link
    # to the containing instance attribute
    def save
      create_file
      true
    end
    
    def create_file
      opts = {:content_type => "#{self.content_type}"}
      result = self.instance.file_resource(self).post(File.read(self.tempfile), opts) do |resp, req, res, &block|  
        case resp.code 
        when 400

          # https://www.parse.com/docs/ios/api/Classes/PFConstants.html
          error_response = JSON.parse(resp)
          pe = ParseError.new(error_response["code"]).to_array
          self.errors.add(pe[0], pe[1])
          
        when 201
          success_response = JSON.parse(resp)
          @name = success_response['name']
          @url  = success_response['url']
          @dirty = true
        else
          # do what?
        end

        self
      end

      self
    end
    
    def destroy
      self.instance.delete_file_resource(self).delete
      nil
    end
    
    def cleanup_filename(filename)
      filename.gsub(RESTRICTED_CHARACTERS, '_')
    end
    
  end
end