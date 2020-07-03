module Algolia
  class SynonymIterator < PaginatorIterator
    def get_endpoint
      path_encode('1/indexes/%s/synonyms/search', @index_name)
    end
  end
end
