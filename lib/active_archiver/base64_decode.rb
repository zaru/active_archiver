module ActiveArchiver
  class Base64Decode < StringIO
    def self.create_from_canvas_base64(str, file_name)
      return nil if str.nil?
      head, data = str.split(",", 2)
      return nil if data.nil?
      _, mime_type = head.split(/:|;/)
      bin = Base64.decode64(data)

      self.new(bin, mime_type, file_name)
    end

    def initialize(blob, content_type, file_name)
      super(blob)
      @content_type = content_type
      @file_name = file_name
      self
    end

    def original_filename
      @file_name
    end

    def content_type
      @content_type
    end
  end
end