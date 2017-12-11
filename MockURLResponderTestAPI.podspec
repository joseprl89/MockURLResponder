Pod::Spec.new do |s|
  s.name         = "MockURLResponderTestAPI"
  s.version      = "0.2.5"
  s.summary      = "Libary which make it possible to mock Respones from UITests target"
  s.homepage     = "https://github.com/TheAdamBorek/MockURLResponder"
  s.license      = "MIT"
  s.authors             = { "Josep Rodriguez" => "josep.rodriguez@tigerspike.com",
                            "Adam Borek" => "adam.borek@tigerspike.com"
                          }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/TheAdamBorek/MockURLResponder.git", :tag => "#{s.version}" }
  s.source_files  = "MockURLResponderTestAPI/*.swift", "MockURLResponder/Response/*.swift"
end
