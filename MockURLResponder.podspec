Pod::Spec.new do |s|
  s.name          = "MockURLResponder"
  s.version       = "0.2.2"
  s.platform      = :ios, '9.0'
  s.summary       = "An iOS network mocking DSL library with minimal setup required."
  s.homepage      = "https://github.com/TheAdamBorek/MockURLResponder"
  s.license       = "MIT"
  s.author        = { "Josep" => "https://joseprl89.github.io" }
  s.source        = { :git => "https://github.com/TheAdamBorek/MockURLResponder.git", :tag => "#{s.version}" }
  s.source_files  = "MockURLResponder/**/*.swift"
end
