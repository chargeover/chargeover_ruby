module Chargeover

  class Invoice < Resource

    self.prefix = '/invoice'

    attr_accessor :invoice_id,
        :currency_id,
        :terms_id,
        :token,
        :refnumber,
        :bill_addr1,
        :bill_addr2,
        :bill_addr3,
        :bill_city,
        :bill_state,
        :bill_country,
        :bill_postcode,
        :bill_notes,
        :ship_addr1,
        :ship_addr2,
        :ship_addr3,
        :ship_city,
        :ship_state,
        :ship_country,
        :ship_postcode,
        :ship_notes,
        :custom_1,
        :custom_2,
        :custom_3,
        :currency_symbol,
        :currency_iso4217,
        :invoice_status_name,
        :invoice_status_str,
        :invoice_status_state,
        :total,
        :credits,
        :payments,
        :sum_base,
        :sum_usage,
        :sum_onetime,
        :is_paid,
        :balance,
        :is_void,
        :due_date,
        :terms_name,
        :terms_days,
        :days_overdue,
        :is_overdue,
        :date,
        :bill_block,
        :ship_block,
        :url_permalink,
        :url_paylink,
        :url_pdflink,
        :package_id,
        :customer_id,
        :line_items,
        :void_datetime,
        :subtotal,
        :taxes


    def self.find_all_by_customer_id(customer_id, sort = '', options = [])
      filter = "?where=customer_id:EQUALS:#{customer_id}"

      query = options.map{ |option| "#{option[:field]}:#{option[:operator]}:#{option[:value]}"}.join(',')

      if query &&query.length > 0
        filter += ',' + query
      end

      if sort.length > 0
        filter += '&order=' + sort
      end

      response = get(base_url + filter)
      invoices = []
      response.each do |invoice|
        invoices << new(invoice)
      end
      invoices
    end

    def self.find_all_by_package_id(package_id, sort = '', options = [], limit = 100, offset = 0)
      filter = "?where=package_id:EQUALS:#{package_id}"

      query = options.map{ |option| "#{option[:field]}:#{option[:operator]}:#{option[:value]}"}.join(',')

      if query &&query.length > 0
        filter += ',' + query
      end

      if sort.length > 0
        filter += '&order=' + sort
      end

      filter += "limit=#{limit}?offset=#{offset}"

      response = get(base_url + filter)
      invoices = []
      response.each do |invoice|
        invoices << new(invoice)
      end
      invoices
    end

    def void
      post(base_url + "/#{self.invoice_id}?action=void")
    end

    def send_email(options = {})
      post(base_url + "/#{self.invoice_id}?action=email", options)
    end

private

    attr_writer :write_datetime
  end


end