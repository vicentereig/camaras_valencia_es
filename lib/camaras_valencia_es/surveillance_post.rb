require 'active_support/core_ext/object/blank'
require 'httparty'
require 'cgi'
require 'json'


module CamarasValenciaEs
  class SurveillancePost
    include CamarasValenciaEs::Util::V8Unescaper
    include CamarasValenciaEs::Util::LatLonConverter

    attr_accessor :id, :x, :y, :icon_type, :street_name, :camera_count, :neighbourhood

    def initialize(id, x, y, icon_type)
      @id, @x, @y, @icon_type = id, x, y, icon_type
      convert_to_lat_long
    end

    #attribute :id,        type: String,        match: 'idgrupo'
    #attribute :x,         type: defuck_coords, match: 'latitud'
    #attribute :y,         type: defuck_coords, match: 'longitud'
    #attribute :icon_type, type: String,        match: 'tipoicono'
    #
    #parser WhyDidntTheyUseProperJSON

    def self.parse(json)
      defuck_coords = ->(v) {
        CGI.unescape(v).gsub(/,/,".").to_f
      }

      serializable = JSON.parse(json)
      # This JSON structure is fucking weird just to implement
      # a simple array of objects. An Array of Hashe would have been more than enough.
      # What they call latitude, and longitude is in fact UTM X/Y.
      attrs = serializable['datos']
      attrs['idgrupo'].collect.with_index { |idgrupo, i|
        x, y = defuck_coords.call(attrs['longitud'][i]), defuck_coords.call(attrs['latitud'][i])
        self.new(attrs['idgrupo'][i], x, y, attrs['tipoicono'][i])
      }
    end

    include HTTParty
    base_uri 'http://camaras.valencia.es/web/'
    headers 'Content-type' => 'application/json'

    def self.all(opts={})
      response_body = SurveillancePost.get('/infogrupos.asp', query: SurveillancePost.query_params(opts.delete(:bbox))).body
      self.parse(response_body)
    end

    def load_attributes
      response_body      = SurveillancePost.get('/infogrupo.asp', query: {idgrupo: id}).body
      body_parts         = response_body.split(/,/)
      self.camera_count  = body_parts.pop.to_i
      body_parts         = body_parts.first.split(/-/)

      self.neighbourhood = unescape(body_parts.pop)
      self.street_name   = unescape(body_parts.pop)

      response_body
    end

    def cameras
      @cameras ||= SurveillanceCamera.all(self.id)
    end

    def to_attributes
      {
        remote_id: self.id,
        location: [self.latlon.y, self.latlon.x],
        address:
        {
          street_name:        (self.street_name || "").strip,
          neighbourhood_name: (self.neighbourhood || "").strip
        },
        surveillance_cameras: self.cameras_to_attributes
      }
    end

    def cameras_to_attributes
      self.cameras.map(&:to_attributes)
    end

    protected
      def self.query_params(bbox)
        return {} unless bbox.present?
        {lat1: bbox[0], long1: bbox[1], lat2: bbox[2], long2: bbox[3]}
      end
  end
end