Gem::Specification.new do |s|
  s.name = "cloudseed"
  s.version = "0.1.0"
  s.summary = "Rack-based helper for CloudFront custom origins"
  s.description = "CloudSeed is a Rack-based utility to manage backend delivery of CloudFront custom origins."

  s.files = Dir["Rakefile", "lib/**/*"]

  s.add_dependency "rack", ">= 1.0.0"

  s.authors = ["Kurt Mackey"]
  s.email = "mrkurt@gmail.com"
  s.homepage = "http://github.com/mrkurt/cloudseed/"
end
