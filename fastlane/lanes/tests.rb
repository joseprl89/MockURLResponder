platform :ios do
  desc "Runs the tests for the SDK and the sample app."
  lane :tests do
    scan(
      workspace: "MockURLResponder.xcworkspace",
      scheme: "MockURLResponder"
    )

    scan(
      workspace: "SampleApp/MockURLResponderSampleApp.xcworkspace",
      scheme: "MockURLResponderSampleApp"
    )
  end
end
