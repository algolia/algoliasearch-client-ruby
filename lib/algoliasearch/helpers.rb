module Helpers
  def self.convert_to_json(body)
    body.is_a?(String) ? body : MultiJson.dump(body)
  end
end
