Pod::Spec.new do |s|
  s.name          = "MockURLResponder"
  s.version       = "0.3.1"
  s.platform      = :ios, '9.0'
  s.summary       = "An iOS network mocking DSL library with minimal setup required."
  s.homepage      = "https://github.com/joseprl89/MockURLResponder"
  s.license       = "MIT"
  s.authors       = {
     "Josep Rodriguez" => "josep.rodriguez@tigerspike.com",
     "Adam Borek" => "adam.borek@tigerspike.com"
  }
  s.source        = { :git => "https://github.com/joseprl89/MockURLResponder.git", :tag => "#{s.version}" }
  s.source_files  = "MockURLResponder/**/*.swift"
  s.swift_version = '4.2'
end
