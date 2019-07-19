Pod::Spec.new do |s|
  s.name         = "MockURLResponderTestAPI"
  s.version      = "0.3.1"
  s.summary      = "API to control the MockURLResponder setup."
  s.homepage     = "https://github.com/joseprl89/MockURLResponder"
  s.license      = "MIT"
  s.authors      = {
     "Josep Rodriguez" => "josep.rodriguez@tigerspike.com",
     "Adam Borek" => "adam.borek@tigerspike.com"
  }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/joseprl89/MockURLResponder.git", :tag => "#{s.version}" }
  s.source_files  = "MockURLResponderTestAPI/*.swift", "MockURLResponder/Response/*.swift"
  s.swift_version = '5.0'
end
