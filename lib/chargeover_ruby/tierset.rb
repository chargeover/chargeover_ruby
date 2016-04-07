module Chargeover
  class Tierset < Resource

    attr_accessor :base,
                  :pricemodel,
                  :paycycle,
                  :tierset_id,
                  :setup,
                  :percent,
                  :write_datetime,
                  :mod_datetime,
                  :setup_formatted,
                  :base_formatted,
                  :percent_formatted,
                  :pricemodel_desc,
                  :tiers

  end
end
