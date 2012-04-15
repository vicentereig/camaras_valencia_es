require 'proj4'

module CamarasValenciaEs
  module Util
    module LatLonConverter
      extend ActiveSupport::Concern

      included do
        attr_accessor :latlon
      end

      protected
        def convert_to_lat_long
          # http://spatialreference.org/ref/epsg/23030/proj4/
          @utm ||= Proj4::Projection.new proj: "utm", zone: "30N", units: "m", ellps: 'intl'
          @point  = Proj4::Point.new self.x, self.y
          self.latlon = @utm.inverseDeg @point
        end
    end
  end
end