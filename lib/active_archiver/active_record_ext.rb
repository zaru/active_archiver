module ActiveArchiver
  module ActiveRecordExt

    def self.included(model)
      model.extend ClassMethods
    end

    def export(includes: [])
      CarrierWave::Uploader::Base.active_archiver_blob_data = true
      hash = {}
      hash[:attributes] = self.serializable_hash
      hash[:associations] = []
      includes.each do |model|
        if self.send(model).respond_to?(:class_name)
          model_name = self.send(model).class_name
          self.send(model).all.each do |r|
            hash[:associations] << {
              model_name: model_name,
              association_name: model,
              attributes: r.serializable_hash
            }
          end
        else
          model_name = self.send(model).class.class_name
          hash[:associations] << {
            model_name: model_name,
            association_name: model,
            attributes: self.send(model).serializable_hash
          }
        end
      end
      CarrierWave::Uploader::Base.active_archiver_blob_data = false
      hash.to_json
    end

    def archive(basename = ["", ".json"], dir = Dir.tmpdir)
      Tempfile.open(basename, dir) do |fp|
        fp.puts export
        fp
      end
    end

    module ClassMethods
      def import(hash)
        obj = self.new(hash["attributes"])
        hash["associations"].each do |r|
          if obj.send(r["association_name"]).respond_to?(:<<)
            obj.send("#{r['association_name']}") << Object.const_get(r["model_name"]).new(r["attributes"])
          else
            obj.send("#{r['association_name']}=", Object.const_get(r["model_name"]).new(r["attributes"]))
          end
        end
        obj
      end
    end
  end
end