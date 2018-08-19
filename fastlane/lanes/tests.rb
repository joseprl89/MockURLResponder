platform :ios do

  desc "Runs the tests for the SDK and sample app."
  lane :all_tests do
    test_sdk
    test_sample_app
  end

  desc "Runs the tests for the SDK."
  lane :test_sdk do
    scan(
      workspace: "MockURLResponder.xcworkspace",
      scheme: "MockURLResponder"
    )
  end

  desc "Runs the tests for the Sample App."
  lane :test_sample_app do
    scan(
      workspace: "SampleApp/MockURLResponderSampleApp.xcworkspace",
      scheme: "MockURLResponderSampleApp"
    )
  end
end
