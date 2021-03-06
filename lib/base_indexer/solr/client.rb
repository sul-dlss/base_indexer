require 'retries'
require 'rsolr'
require 'rest-client'
module BaseIndexer
  module Solr
    # Processes adds and deletes to the solr core
    class Client
      include DiscoveryIndexer::Logging
      
      def self.logging_handler(id)
        proc do |exception, attempt_number, _total_delay|
          DiscoveryIndexer::Logging.logger.error "#{exception.class} on attempt #{attempt_number} for #{id}"
        end
      end

      # Add the document to solr, retry if an error occurs.
      # See https://github.com/ooyala/retries for docs on with_retries.
      # @param id [String] the document id, usually it will be druid.
      # @param solr_doc [Hash] a Hash representation of the solr document
      # @param solr_connector [RSolr::Client]  is an open connection with the solr core
      # @param max_retries [Integer] the maximum number of tries before fail
      def self.add(id, solr_doc, solr_connector, max_retries = 10)
        with_retries(max_tries: max_retries, handler: logging_handler(id), base_sleep_seconds: 1, max_sleep_seconds: 5) do |attempt|
          DiscoveryIndexer::Logging.logger.debug "Attempt #{attempt} for #{id}"

          if allow_update?(solr_connector) && doc_exists?(id, solr_connector)
            update_solr_doc(id, solr_doc, solr_connector)
            DiscoveryIndexer::Logging.logger.info "Updating #{id} on attempt #{attempt}"
          else
            solr_connector.add(solr_doc, :add_attributes => {:commitWithin => 10000})
            DiscoveryIndexer::Logging.logger.info "Indexing #{id} on attempt #{attempt}"
          end

          DiscoveryIndexer::Logging.logger.info "Completing #{id} successfully on attempt #{attempt}"
        end
      end

      # Add the document to solr, retry if an error occurs.
      # See https://github.com/ooyala/retries for docs on with_retries.
      # @param id [String] the document id, usually it will be druid.
      # @param solr_connector[RSolr::Client]  is an open connection with the solr core
      # @param max_retries [Integer] the maximum number of tries before fail
      def self.delete(id, solr_connector, max_retries = 10)
        with_retries(max_tries: max_retries, handler: logging_handler(id), base_sleep_seconds: 1, max_sleep_seconds: 5) do |attempt|
          DiscoveryIndexer::Logging.logger.debug "Attempt #{attempt} for #{id}"

          solr_connector.delete_by_id(id, :add_attributes => {:commitWithin => 10000})
          DiscoveryIndexer::Logging.logger.info "Deleting #{id} on attempt #{attempt}"
          DiscoveryIndexer::Logging.logger.info "Completing #{id} successfully on attempt #{attempt}"
        end
      end

      # @param solr_connector [RSolr::Client]  is an open connection with the solr core
      # @return [Boolean] true if the solr core allowing update feature
      def self.allow_update?(solr_connector)
        solr_connector.options.include?(:allow_update) ? solr_connector.options[:allow_update] : false
      end

      # @param id [String] the document id, usually it will be druid.
      # @param solr_connector [RSolr::Client]  is an open connection with the solr core
      # @return [Boolean] true if the solr doc defined by this id exists
      def self.doc_exists?(id, solr_connector)
        response = solr_connector.get 'select', params: { q: 'id:"' + id + '"', defType: 'lucene' }
        response['response']['numFound'] == 1
      end

      # It is an internal method that updates the solr doc instead of adding a new one.
      # @param id [String] the document id, usually it will be druid.
      # @param solr_doc [Hash] is the solr doc in hash format
      # @param solr_connector [RSolr::Client]  is an open connection with the solr core
      def self.update_solr_doc(id, solr_doc, solr_connector)
        # update_solr_doc can't used RSolr because updating hash doc is not supported
        #  so we need to build the json input manually
        hash = { id: id }
        solr_doc.each do |k,v|
          hash[k] = { set: v } unless k.to_sym == :id
        end
        solr_connector.update params: { commitWithin: 10000 }, data: Array.wrap(hash).to_json, headers: { 'Content-Type' => 'application/json' }
      end
    end
  end
end
