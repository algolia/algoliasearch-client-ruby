module Algolia
  module Account
    class Client
      class << self
        def copy_index(src_index, dest_index, opts = {})
          raise AlgoliaError, 'The indices are on the same application. Use Algolia::Search::Client.copy_index instead.' if src_index.config.app_id == dest_index.config.app_id

          begin
            dest_settings = dest_index.get_settings

            raise AlgoliaError, 'Destination index already exists. Please delete it before copying index across applications.' if dest_settings
          rescue AlgoliaHttpError => e
            raise e if e.code != 404
          end

          responses = MultipleResponse.new

          # Copy settings
          settings = src_index.get_settings
          responses.push(dest_index.set_settings(settings, opts))

          # Copy synonyms
          synonyms = src_index.browse_synonyms
          responses.push(dest_index.save_synonyms(synonyms, opts))

          # Copy rules
          rules = src_index.browse_rules
          responses.push(dest_index.save_rules(rules, opts))

          # Copy objects
          objects = src_index.browse_objects
          responses.push(dest_index.save_objects(objects, opts))

          responses
        end

        def copy_index!(src_index, dest_index, opts = {})
          response = copy_index(src_index, dest_index, opts)
          response.wait(opts)
        end
      end
    end
  end
end
