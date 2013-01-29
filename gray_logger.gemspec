Gem::Specification.new do |s|
  s.name          = 'gray_logger'
  s.version       = '0.12.0'
  s.date          = Date.today.strftime("%Y-%m-%d")
  s.summary       = "Rack Middleware to log custom stuff to Graylog2"
  s.description   = "GrayLogger is a middleware for Rack to easily log custom stuff to Graylog2"
  s.authors       = ["Benjamin Behr"]
  s.email         = 'benny@digitalbehr.de'

  s.files         = Dir.glob("lib/**/*") + %w(CHANGELOG.md README.md Rakefile)

  s.add_dependency("gelf")

  s.add_development_dependency "minitest"
  s.add_development_dependency "minitest-colorize"
  s.add_development_dependency "guard-minitest"
  s.add_development_dependency "rake"
  s.add_development_dependency "growl"
  s.add_development_dependency "mocha"
end
