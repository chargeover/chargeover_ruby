module Chargeover
  class CreditCard < Resource

    self.prefix = '/creditcard'

    attr_accessor :creditcard_id,
        :external_key,
        :type,
        :token,
        :expdate,
        :write_datetime,
        :write_ipaddr,
        :mask_number,
        :name,
        :expdate_month,
        :expdate_year,
        :expdate_formatted,
        :type_name,
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

    def self.destroy(card_id)
      delete(base_url + "/#{card_id}")
    end
  end
end
