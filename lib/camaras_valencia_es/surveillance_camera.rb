require 'httparty'

module CamarasValenciaEs
  class SurveillanceCamera
    include CamarasValenciaEs::Util::V8Unescaper
    include CamarasValenciaEs::Util::LatLonConverter

    attr_accessor :id, :target, :address, :x, :y, :source, :type, :icon_type

    def initialize(id, x, y, target, source, address, type, icon_type)
      @id, @x, @y, @target, @source, @address, @type, @icon_type = id, x, y, target, source, address, type, icon_type
      convert_to_lat_long
    end

    # TODO: DRY. Check SurveillancePost.parse
    def self.parse(json)
      defuck_coords = ->(v) {
        unescape(v).gsub(/,/,".").to_f
      }

      serializable = JSON.parse(json)
      # This JSON structure is fucking weird just for representing
      # a simple array of objects. An Array of Hashes would have been more than enough.
      # What they call latitude, and longitude is in fact EPSG 23030 - ed50 / utm zone 30n.
      attrs = serializable['datos']
      attrs['idcamara'].collect.with_index { |idgrupo, i|
        x, y = defuck_coords.call(attrs['longitud'][i]), defuck_coords.call(attrs['latitud'][i])
        target, source, address = unescape(attrs['destino'][i]), unescape(attrs['origen'][i]), unescape(attrs['direccion'][i])
        self.new(attrs['idcamara'][i], x, y, target, source, address, attrs['tipo'][i], attrs['tipoicono'][i])
      }
    end

    include HTTParty

    base_uri 'http://camaras.valencia.es/web/'
    headers 'Content-type' => 'application/json'

    def self.all(post_id)
      self.parse SurveillanceCamera.get('/infocamaras.asp', query: { idgrupo: post_id}).body
    end

    def filename
      @flags_and_filename ||= unescape(SurveillanceCamera.get('/imagen.asp', query: { idcamara: self.id}).body).split(';')
      @flags_and_filename[1]
    end

    def media
      @flags_and_filename ||= unescape(SurveillanceCamera.get('/imagen.asp', query: { idcamara: self.id}).body).split(';')
      (@flags_and_filename[0] == '0')? :image : :video
    end

    # TODO
    def to_attributes
      {
        location: [self.latlon.y, self.latlon.x],
        remote_id: self.id,
        media: self.media,
        filename: self.filename,
        recording_source: self.source,
        recording_target: self.target
      }
    end
  end
end