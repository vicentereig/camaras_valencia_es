require 'active_support/core_ext/object/blank'
require 'httparty'
require 'cgi'
require 'json'

module CamarasValenciaEs
  class SurveillancePost
    attr_accessor :id, :x, :y, :icon_type

    def initialize(id, x, y, icon_type)
      @id, @x, @y, @icon_type = id, x, y, icon_type
    end
    #attribute :id,        type: String,        match: 'idgrupo'
    #attribute :x,         type: defuck_coords, match: 'latitud'
    #attribute :y,         type: defuck_coords, match: 'longitud'
    #attribute :icon_type, type: String,        match: 'tipoicono'
    #
    #parser WhyDidntTheyUseProperJSONParser

    def self.parse(json)
      defuck_coords = ->(v) {
        CGI.unescape(v).gsub(/,/,".").to_f
      }

      serializable = JSON.parse(json)
      # I know this JSON structure is fucking weird just for representing
      # a simple array of objects.
      # Also what they call latitude, and longitude is in fact UTM X/Y.
      attrs = serializable['datos']
      attrs['idgrupo'].collect.with_index { |idgrupo, i|
        x, y = defuck_coords.call(attrs['latitud'][i]), defuck_coords.call(attrs['longitud'][i])
        self.new(attrs['idgrupo'][i], x, y, attrs['tipoicono'][i])
      }
    end

    include HTTParty
    base_uri 'http://camaras.valencia.es/web/'
    headers 'Content-type' => 'application/json'

    def self.all(opts={})
      response_body = SurveillancePost.get('/infogrupos.asp', query: SurveillancePost.query_params(opts.delete(:id))).body
      self.parse(response_body)
    end

    # MAESTRO%20RODRIGO%20-%20CAMP%20DEL%20TURIA,3
    def self.find(id)
      SurveillancePost.get('infogrupo.asp', query: { id: id} )
    end

    protected
    def self.query_params(bbox)
      return {} unless bbox.present?
      {lat1: bbox[0], long1: bbox[1], lat2: bbox[2], long2: bbox[3]}
    end
  end
end