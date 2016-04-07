module Chargeover
  class RecurringPackage < Resource

    self.prefix = '/package'

    attr_accessor :terms_id,
                  :currency_id,
                  :external_key,
                  :token,
                  :nickname,
                  :paymethod,
                  :paycycle,
                  :bill_addr1,
                  :bill_addr2,
                  :bill_addr3,
                  :bill_city,
                  :bill_state,
                  :bill_postcode,
                  :bill_country,
                  :bill_notes,
                  :ship_addr1,
                  :ship_addr2,
                  :ship_addr3,
                  :ship_city,
                  :ship_state,
                  :ship_country,
                  :ship_postcode,
                  :ship_notes,
                  :creditcard_id,
                  :ach_id,
                  :tokenized_id,
                  :custom_1,
                  :custom_2,
                  :custom_3,
                  :amount_collected,
                  :amount_invoiced,
                  :amount_due,
                  :next_invoice_datetime,
                  :package_id,
                  :customer_id,
                  :package_status_id,
                  :package_status_name,
                  :package_status_str,
                  :package_status_state,
                  :item_type,
                  :holduntil_datetime,
                  :cancel_datetime

    def self.find_all_by_customer_id(customer_id)
      response = get(base_url + "?where=customer_id:EQUALS:#{customer_id}")
      packages = []
      response.each do |package|
        packages << RecurringPackage.find(package['package_id'])
      end
      packages
    end

    def line_items=(line_items)
      @line_items = line_items
    end

    def line_items
      items = []
      if @line_items
        @line_items.each do |line_item|
          items << Chargeover::LineItem.new(line_item)
        end
      end
      items
    end

    def credit_card
      unless @credit_card
        if self.creditcard_id
          @credit_card = Chargeover::CreditCard.find(self.creditcard_id)
        end
      end
      @credit_card
    end


    def upgrade(old_line_item_id, new_item_id, prorate = true)
      data = {
          line_items: [
              {
                line_item_id: old_line_item_id,
                item_id: new_item_id,
                subscribe_prorate: prorate,
                cancel_prorate: prorate
              }
        ]
      }

      response = post(base_url + "/#{self.package_id}?action=upgrade", data)

      if response
        Chargeover::RecurringPackage.find(self.package_id)
      else
        nil
      end
    end

    # custom update, using low level api
    def custom_upgrade(line_item_data)
      response = post(base_url + "/#{self.package_id}?action=upgrade", line_item_data)

      if response
        Chargeover::RecurringPackage.find(self.package_id)
      else
        nil
      end
    end

    # note, this is only for FLAT pricing models
    def change_line_item_price(line_item, amount, description = nil)

      data = {
          line_items: [
              {
                line_item_id: line_item.line_item_id,
                item_id: line_item.item_id,
                tierset: {
                    base: amount.to_s,
                    pricemodel: "fla",
                    paycycle: line_item.tierset.paycycle
                }
              }
          ]
      }

      if description
        data[:line_items].first[:descrip] = description
      end

      response = post(base_url + "/#{self.package_id}?action=upgrade", data)

      if response
        Chargeover::RecurringPackage.find(self.package_id)
      else
        nil
      end
    end

    # note this is for FLAT pricing models
    def add_line_item(item, amount, description = nil, paycycle = 'mon')
      data = {
          line_items: [
              {
                  item_id: item.item_id,
                  tierset: {
                      base: amount.to_s,
                      pricemodel: "fla",
                      paycycle: paycycle
                  }
              }
          ]
      }

      if description
        data[:line_items].first[:descrip] = description
      end

      response = post(base_url + "/#{self.package_id}?action=upgrade", data)

      if response
        Chargeover::RecurringPackage.find(self.package_id)
      else
        nil
      end
    end

    # note this is for FLAT pricing models
    def cancel_line_item(item)
      data = {
          line_items: [
              {
                  item_id: item.item_id,
                  tierset: {
                      base: amount.to_s,
                      pricemodel: "fla",
                      paycycle: paycycle
                  }
              }
          ]
      }

      if description
        data[:line_items].first[:descrip] = description
      end

      response = post(base_url + "/#{self.package_id}?action=upgrade", data)

      if response
        Chargeover::RecurringPackage.find(self.package_id)
      else
        nil
      end
    end


    def update_paymethod(pay_method, options = {})
      data = {
          paymethod: pay_method
      }
      data.merge!(options)
      post(base_url + "/#{self.package_id}?action=paymethod", data)
      Chargeover::RecurringPackage.find(self.package_id)
    end

    def update_paycycle(pay_cycle)
      post(base_url + "/#{self.package_id}?action=paycycle", { paycycle: pay_cycle })
      Chargeover::RecurringPackage.find(self.package_id)
    end

    def update_hold_date(hold_date)
      post(base_url + "/#{self.package_id}?action=hold", { holduntil_datetime: hold_date })
      Chargeover::RecurringPackage.find(self.package_id)
    end

    def update_custom_1(new_value)
      put(base_url + "/#{self.package_id}", { custom_1: new_value })
      Chargeover::RecurringPackage.find(self.package_id)
    end

    def update_payment_terms(new_value)
      put(base_url + "/#{self.package_id}", { terms_id: new_value })
      Chargeover::RecurringPackage.find(self.package_id)
    end

    def cancel
      post(base_url + "/#{self.package_id}?action=cancel")
    end

    def latest_invoice
      invoices = Invoice.find_all_by_package_id(self.package_id, "invoice_date:DESC", [], 1)
      invoices.first
    end

    def find_line_item_by_item_external_key(key)
      item = nil
      self.line_items.each do |line_item|
        if line_item.item.external_key == key
          item = line_item
        end
      end
      item
    end

    def update_attributes(attributes)
      response = put(base_url + "/#{self.package_id}", attributes)
      Chargeover::RecurringPackage.find(response['id'])
    end

private

    attr_writer :write_datetime, :mod_datetime, :currency_symbol, :currency_iso4217

  end
end