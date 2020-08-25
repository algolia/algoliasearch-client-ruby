require_relative 'base_test'
require 'date'

class RecommendationClientTest < BaseTest
  describe 'Recommendation client' do
    def test_recommendation_client
      client                   = Algolia::Recommendation::Client.create(APPLICATION_ID_1, ADMIN_KEY_1)
      personalization_strategy = {
        eventsScoring: [
          { eventName: 'Add to cart', eventType: 'conversion', score: 50 },
          { eventName: 'Purchase', eventType: 'conversion', score: 100 }
        ],
        facetsScoring: [
          { facetName: 'brand', score: 100 },
          { facetName: 'categories', score: 10 }
        ],
        personalizationImpact: 0
      }

      client.set_personalization_strategy(personalization_strategy)
      response = client.get_personalization_strategy

      assert_equal response, personalization_strategy
    end
  end
end
