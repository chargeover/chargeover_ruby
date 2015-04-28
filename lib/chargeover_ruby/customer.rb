module Chargeover
  class Customer < Resource

    self.prefix = '/customer'

    attr_reader   :customer_id,
                  :mod_datetime,
                  :mod_ipaddr,
                  :write_datetime,
                  :write_ipaddr,
                  :paid,
                  :total,
                  :balance,
                  :url_paymethodlink,
                  :superuser_name,
                  :superuser_first_name,
                  :superuser_last_name,
                  :superuser_phone,
                  :superuser_email

    attr_accessor :external_key,
                  :superuser_id,
                  :token,
                  :company,
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
                  :ship_postcode,
                  :ship_country,
                  :ship_notes,
                  :terms_id,
                  :class_id,
                  :custom_1,
                  :custom_2,
                  :custom_3,
                  :admin_id,
                  :campaign_id,
                  :custtype_id,
                  :currency_id,
                  :no_taxes,
                  :no_dunning,
                  :terms_name,
                  :terms_days,
                  :currency_symbol,
                  :currency_iso4217,
                  :ship_block,
                  :bill_block,
                  :superuser_username,
                  :tags

    def self.destroy(customer_id)
      delete(base_url + "/#{customer_id}")
    end

    def update_attributes(attributes)
      response = put(base_url + "/#{self.customer_id}", attributes)
      Chargeover::Customer.find(response['id'])
    end

    def recurring_packages
      RecurringPackage.find_all_by_customer_id(self.customer_id)
    end

    def invoices(sort = '', options = [])
      Invoice.find_all_by_customer_id(self.customer_id, sort, options)
    end

    def latest_invoice
      invoices = Invoice.find_all_by_customer_id(self.customer_id, "invoice_date:DESC")
      invoices.first
    end

    def contacts
      Contact.find_all_by_customer_id(self.customer_id)
    end

private
    attr_writer :customer_id,
                :write_datetime,
                :write_ipaddr,
                :mod_datetime,
                :mod_ipaddr,
                :paid,
                :total,
                :balance,
                :url_paymethodlink,
                :display_as,
                :superuser_name,
                :superuser_first_name,
                :superuser_last_name,
                :superuser_phone,
                :superuser_email
  end
end