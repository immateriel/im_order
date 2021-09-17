$:.push File.expand_path("../lib", __FILE__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "im_order"
  s.version     = "1.1.0"
  s.authors     = ["Julien Boulnois"]
  s.email       = ["jboulnois@immateriel.fr"]
  s.homepage    = "http://www.immateriel.fr"
  s.summary     = "immatériel.fr order web-services helper"
  s.description = "immatériel.fr order web-services helper"

  s.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  s.test_files = Dir["test/**/*"]

  s.add_dependency "nokogiri"

  s.add_development_dependency "bundler"
  s.add_development_dependency "rake"
  s.add_development_dependency "shoulda"
  s.add_development_dependency "rdoc"
  s.add_development_dependency "simplecov"
end
