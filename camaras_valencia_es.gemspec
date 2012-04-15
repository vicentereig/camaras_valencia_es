# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "camaras_valencia_es/version"

Gem::Specification.new do |s|
  s.name        = "camaras_valencia_es"
  s.version     = CamarasValenciaEs::VERSION
  s.authors     = ["Vicente Reig Rincón de Arellano"]
  s.email       = ["vicente.reig@gmail.com"]
  s.homepage    = "http://github.com/vicentereig/camaras_valencia_es"
  s.summary     = %q{A client to access http://camaras.valencia.es traffic CCTV information.}
  s.description = %q{A RESTful wrapper to the RESTful-like API at http://camaras.valencia.es to access traffic CCTV information.}

  s.rubyforge_project = "camaras_valencia_es"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  s.add_runtime_dependency "httparty"
  s.add_runtime_dependency "therubyracer"
  s.add_runtime_dependency "proj4rb"
  #s.add_runtime_dependency "active_support", ">= 3.0.0"
end
