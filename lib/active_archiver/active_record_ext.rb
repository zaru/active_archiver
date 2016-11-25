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
      hash
    end

    def archive(includes: [], basename: ["", ".json"], dir: Dir.tmpdir)
      Tempfile.open(basename, dir) do |fp|
        fp.puts export(includes: includes).to_json
        fp
      end
    end

    module ClassMethods
      def import(hash)
        hash = hash.with_indifferent_access
        obj = self.find_or_initialize_by(id: hash["attributes"]["id"])
        obj.attributes = hash["attributes"]
        obj = restore_image(obj, hash)
        hash["associations"].each do |r|
          r_obj = Object.const_get(r["model_name"]).find_or_initialize_by(id: r["attributes"]["id"])
          r_obj.attributes = r["attributes"]
          r_obj = restore_image(r_obj, r)
          if obj.send(r["association_name"]).respond_to?(:<<)
            obj.send("#{r['association_name']}") << r_obj
          else
            obj.send("#{r['association_name']}=", r_obj)
          end
        end
        obj.save
      end

      private

      def restore_image(obj, data)
        blobs = data["attributes"].select{|k,v| v.is_a?(Hash) && v.has_key?("blob") }
        blobs.each do |key, blob|
          obj.send("#{key}=", ActiveArchiver::Base64Decode.create_from_canvas_base64(blob["blob"], blob["file_name"]))
        end
        obj
      end
    end
  end
end