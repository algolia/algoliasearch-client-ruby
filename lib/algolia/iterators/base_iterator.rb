module Algolia
  class BaseIterator
    include Helpers
    include Enumerable

    attr_reader :transporter, :index_name, :opts

    def initialize(transporter, index_name, opts)
      @transporter = transporter
      @index_name  = index_name
      @opts        = opts
      @response    = nil
    end
  end
end
