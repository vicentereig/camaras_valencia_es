module CamarasValenciaEs
  class SurveillanceCamera
    include HTTParty

    #base_uri 'http://camaras.valencia.es/web/infocamaras.asp?idgrupo=121&acc=0&iditinerario=-1'
    base_uri 'http://camaras.valencia.es/web/'

    def self.all(post_id)
      SurveillanceCamera.get('infocamaras.asp', query: { idgrupo: post_id})
    end

    def self.find(id)
      SurveillanceCamera.get('image.asp', query: { idcamara: post_id})
    end
  end
end