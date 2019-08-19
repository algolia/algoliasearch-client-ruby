module Algolia

  def self.get_object_id_position(res, object_id)
    res['hits'].each_with_index do |hit, i|
      if hit['objectID'] == object_id
        return i
      end
    end
    -1
  end

end