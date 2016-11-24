require "active_archiver/version"
require "carrierwave/serialization"
require "active_archiver/active_record_ext"

module ActiveArchiver
end

ActiveSupport.on_load :active_record do
  ActiveRecord::Base.include(ActiveArchiver::ActiveRecordExt)
end