require 'active_support/core_ext/object/blank'

module CamarasValenciaEs
  class SurveillancePost
    include HTTParty
    base_uri 'http://camaras.valencia.es/web/'

    def self.all(opts={})
      SurveillancePost.get('infogrupos.asp', query: query_params(opts.delete(:id)))
    end

    # MAESTRO%20RODRIGO%20-%20CAMP%20DEL%20TURIA,3
    def self.find(id)
      SurveillancePost.get('infogrupo.asp', query: { id: id} )
    end

    protected
    def query_params(bbox)
      return {} unless bbox.present?
      {lat1: bbox[0], long1: bbox[1], lat2: bbox[2], long2: bbox[3]}
    end
  end
end