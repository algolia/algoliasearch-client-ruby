module Algolia
  class RuleIterator < PaginatorIterator
    def get_endpoint
      path_encode('1/indexes/%s/rules/search', @index_name)
    end
  end
end
