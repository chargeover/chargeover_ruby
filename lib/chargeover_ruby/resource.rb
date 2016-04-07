module Chargeover

  class Resource

    attr_accessor :config

    class << self
      attr_accessor :prefix

      def base_url
        Chargeover.base_url + self.prefix
      end

      def find_by_external_key(external_key)
        response = get(base_url + "?where=external_key:EQUALS:#{external_key}")
        new(response.first)
      end

      def find(id)
        response = get(base_url + "/#{id}")
        new(response)
      end

      def all
        limit = 100
        offset = 0
        objs = []

        response = get(base_url + "?limit=#{limit}&offset=#{offset}")

        while response.length > 0
          objs = []
          response.each do |obj|
            objs << new(obj)
          end
          offset += 100
          response = get(base_url + "?limit=#{limit}&offset=#{offset}")
        end

        objs
      end

      def query(options = [], offset = 0, limit = 100, sort = '')
        objs = []

        url = build_query(options, offset, limit, sort)
        url = build_query(options, offset, limit, sort)

        response = get(url)

        response.each do |obj|
            objs << new(obj)
        end

        objs
      end

      def create(attributes)
        response = post(base_url, attributes)
        self.find(response['id'])
      end

      def get(url)
        request :get, url
      end

      def post(url, payload = {})
        request :post, url, payload
      end

      def put(url, payload)
        request :put, url, payload
      end

      def delete(url)
        request :delete, url
      end

      def successful_response?(response)
        (response.status == 200 ||
            response.status == 201 ||
            response.status == 202)
      end

      def raise_error(status, message = nil)
        raise ChargeoverException.new(status, message)
      end

      private

      def request(method, url, payload={})
        conn = Faraday.new(url)
        conn.basic_auth(Chargeover.public_key, Chargeover.private_key)
        response = conn.send(method) do |req|
          req.headers['Content-Type'] = 'application/json'
          req.body = payload.to_json unless payload.empty?
        end

        # handle server down errors without parsing the response body
        raise_error(response.status) if response.status == 500

        attributes = JSON.parse(response.body)

        if successful_response?(response)
          attributes['response']
        else
          raise_error(response.status, attributes['message'])
        end
      end

      def build_query(options, offset = 0, limit = 100, sort = '')
        query = "?where=#{options.map{ |option| "#{option[:field].to_s.downcase}:#{option[:operator].to_s.upcase}:#{option[:value]}"}.join(',')}"

        if sort.length > 0
          query += '&order=' + sort
        end

        query += "&limit=#{limit}&offset=#{offset}"
        base_url + query
      end

    end

    def initialize(attributes)
      attributes.each_key do |attribute|

        method_name = "#{attribute}="
        value = attributes[attribute]

        if self.respond_to?(method_name, true)
          if attribute.end_with?('datetime') || attribute == 'date'
            if value != nil && value.length > 0
              send(method_name, DateTime.parse(value))
            end
         else
          send(method_name, value)
          end
        end
      end
    end

    def base_url
      self.class.base_url
    end

    def put(url, payload)
      Chargeover::Resource.put(url, payload)
    end

    def post(url, payload = {})
      Chargeover::Resource.post(url, payload)
    end

  end

end