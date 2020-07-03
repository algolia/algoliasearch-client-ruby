module Algolia
  class PaginatorIterator < BaseIterator
    def initialize(transporter, index_name, opts)
      super(transporter, index_name, opts)

      @data = {
        hitsPerPage: 1000,
        page: 0
      }
    end

    def each
      loop do
        if @response
          if @response[:hits].length
            @response[:hits].each do |hit|
              hit.delete(:_highlightResult)
              yield hit
            end

            if @response[:nbHits] < @data[:hitsPerPage]
              @response = nil
              @data     = {
                hitsPerPage: 1000,
                page: 0
              }
              raise StopIteration
            end
          end
        end
        @response     = @transporter.read(:POST, get_endpoint, @data, @opts)
        @data[:page] += 1
      end
    end

    def get_endpoint
      raise AlgoliaError, 'Method must be implemented'
    end
  end
end
