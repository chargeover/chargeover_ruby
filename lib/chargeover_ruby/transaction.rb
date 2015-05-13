module Chargeover
  class Transaction < Resource

    self.prefix = '/transaction'

    attr_accessor :transaction_id,
                  :gateway_id,
                  :currency_id,
        :token,
        :transaction_date,
        :gateway_status,
        :gateway_transid,
        :gateway_msg,
        :amount,
        :fee,
        :transaction_type,
        :transaction_method,
        :transaction_detail,
        :transaction_datetime,
        :transaction_type_name,
        :currency_symbol,
        :currency_iso4217,
        :customer_id,
        :applied_to

    class << self

      def attempt_payment(customer_id, invoice_ids, amount = nil)
        data = { customer_id: customer_id, applied_to: invoice_ids }
        if amount
          data[:amount] = amount
        end

        response = post(base_url + '?action=pay', data)
        Transaction.find(response['id'])
      end

    end

    def refund(amount = nil)
      data = {}
      unless amount.nil?
        data[:amount] = amount
      end

      response = post(base_url + "/#{self.transaction_id}?action=refund", data)
      Transaction.find(response['id'])
    end
  end
end