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
      hash = recursive_export(hash, self, includes)
      CarrierWave::Uploader::Base.active_archiver_blob_data = false
      hash
    end

    def archive(includes: [], basename: ["", ".json"], dir: Dir.tmpdir)
      Tempfile.open(basename, dir) do |fp|
        fp.puts export(includes: includes).to_json
        fp
      end
    end

    private

    def recursive_export(hash, receiver, models)
      case models
        when Array
          models.each do |v|
            recursive_export(hash, receiver, v)
          end
        when Hash
          models.each do |k,v|
            recursive_export(hash, receiver, k)
            recursive_export(hash, receiver.send(k), v)
          end
        else
          if receiver.respond_to?(:size)
            receiver.each do |rec|
              hash = set_data(hash, rec, models)
            end
          else
            hash = set_data(hash, receiver, models)
          end
      end

      hash
    end

    def set_data(hash, receiver, models)
      if receiver.send(models).respond_to?(:size)
        model_name = receiver.send(models).model_name.plural
        receiver.send(models).all.each do |r|
          hash[:associations] << data_struct(model_name, models, r.serializable_hash)
        end
      else
        model_name = receiver.send(models).model_name.singular
        hash[:associations] << data_struct(model_name, models, receiver.send(models).serializable_hash)
      end
      hash
    end

    def data_struct(model_name, association_name, attributes)
      {
        model_name: model_name,
        association_name: association_name,
        attributes: attributes
      }
    end

    module ClassMethods
      def import(hash, validate: false)
        hash = hash.with_indifferent_access
        obj = self.find_or_initialize_by(id: hash["attributes"]["id"])
        obj.attributes = hash["attributes"]
        obj = restore_image(obj, hash)
        obj.save(validate: validate)

        hash["associations"].each do |r|
          r_obj = Object.const_get(r["model_name"]).find_or_initialize_by(id: r["attributes"]["id"])
          r_obj.attributes = r["attributes"]
          r_obj = restore_image(r_obj, r)
          r_obj.save(validate: validate)
        end
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