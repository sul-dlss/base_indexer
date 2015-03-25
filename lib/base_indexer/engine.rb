require 'active_support/core_ext/numeric/bytes'

module BaseIndexer
  class Engine < ::Rails::Engine
    isolate_namespace BaseIndexer
    # Initialize memory store cache with 50 MB size
    config.cache_store = [:memory_store, {:size => 64.megabytes }]
    config.after_initialize do 
          BaseIndexer.solr_configuration_class_name.constantize.instance.read(Rails.configuration.solr_config_file_path ||= 'test')
          DiscoveryIndexer::Logging.logger = Rails.logger
    end
  end
end

