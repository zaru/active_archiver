module CarrierWave
  module Uploader
    class Base

      @@active_archiver_blob_data = false

      class << self
        def active_archiver_blob_data=(flag)
          @@active_archiver_blob_data = flag
        end
      end

      def serializable_hash(options = nil)
        if @@active_archiver_blob_data
        {
          url: url,
          file_name: File.basename(url),
          blob: "data:#{content_type};base64,#{Base64.strict_encode64(read)}"
        }.merge Hash[versions.map { |name, version| [name, {
          url: version.url,
          file_name: File.basename(version.url),
          blob: "data:#{version.content_type};base64,#{Base64.strict_encode64(version.read)}"
        }] }]
        else
          super
        end
      end
    end
  end
end