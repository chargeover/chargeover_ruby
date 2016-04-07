module Chargeover
  class TokenizedCard < Resource

    self.prefix = '/tokenized'

    attr_accessor :tokenized_id,
                  :type,
                  :token,
                  :customer_id

    def self.find_all_by_customer_id(customer_id)
      filter = "?where=customer_id:EQUALS:#{customer_id}"

      response = get(base_url + filter)
      cards = []
      response.each do |card|
        cards << new(card)
      end
      cards
    end

  end
end
