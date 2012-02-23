require 'httparty'

module CamarasValenciaEs
  class SurveillanceCamera
    attr_accessor :id, :target, :address, :x, :y, :source, :type, :icon_type

    def initialize(id, x, y, target, source, address, type, icon_type)
      @id, @x, @y, @target, @source, @address, @type, @icon_type = id, x, y, target, source, address, type, icon_type
    end

    # TODO: DRY. Check SurveillancePost.parse
    def self.parse(json)
      defuck_coords = ->(v) {
        CGI.unescape(v).gsub(/,/,".").to_f
      }

      serializable = JSON.parse(json)
      # This JSON structure is fucking weird just for representing
      # a simple array of objects. An Array of Hashe would have been more than enough.
      # What they call latitude, and longitude is in fact UTM X/Y.
      attrs = serializable['datos']
      attrs['idcamara'].collect.with_index { |idgrupo, i|
        x, y = defuck_coords.call(attrs['latitud'][i]), defuck_coords.call(attrs['longitud'][i])
        target, source, address = CGI.unescape(attrs['destino'][i]), CGI.unescape(attrs['origen'][i]), CGI.unescape(attrs['direccion'][i])
        self.new(attrs['idcamara'][i], x, y, target, source, address, attrs['tipo'][i], attrs['tipoicono'][i])
      }
    end

    include HTTParty

    base_uri 'http://camaras.valencia.es/web/'
    headers 'Content-type' => 'application/json'

    def self.all(post_id)
      self.parse SurveillanceCamera.get('/infocamaras.asp', query: { idgrupo: post_id}).body
    end

    def image
      CGI.unescape SurveillanceCamera.get('/imagen.asp', query: { idcamara: self.id}).body
    end
  end
end