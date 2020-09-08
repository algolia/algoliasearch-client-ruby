module Algolia
  class ObjectIterator < BaseIterator
    # Custom each function to iterate through the objects
    #
    def each
      loop do
        data = {}

        if @response
          if @response[:hits].length
            @response[:hits].each do |hit|
              yield hit
            end

            if @response[:cursor].nil?
              @response = nil
              raise StopIteration
            else
              data[:cursor] = @response[:cursor]
            end
          end
        end
        @response = @transporter.read(:POST, path_encode('1/indexes/%s/browse', @index_name), data, @opts)
      end
    end
  end
end
