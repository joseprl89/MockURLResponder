platform :ios do
  private_lane :get_version_to_release do
    current_version = get_version_number(
      xcodeproj: "MockURLResponder.xcodeproj",
      target: "MockURLResponder"
    )

    UI.input("Please specify the new version (current = #{current_version}):")
  end

  private_lane :bump_version do |opts|
    increment_version_number(
      version_number: opts[:version_number],
      xcodeproj: "MockURLResponder.xcodeproj"
    )
    increment_version_number(
      version_number: opts[:version_number],
      xcodeproj: "SampleApp/MockURLResponderSampleApp.xcodeproj"
    )
  end

  private_lane :update_sample_app_carthage_dependency do |opts|
    Dir.chdir("..") do
      File.open('SampleApp/Cartfile', 'w') { |file|
        file.write("github \"joseprl89/MockURLResponder\" \"#{opts[:version_number]}\"")
      }
      # Update manually the resolved to avoid having commits with just the bump for this file.
      File.open('SampleApp/Cartfile.resolved', 'w') { |file|
        file.write("github \"joseprl89/MockURLResponder\" \"#{opts[:version_number]}\"")
      }
    end
  end
end
