module Fastlane
  module Actions

    class EndReleaseBranchAction < Action
      def self.run(params)
        UI.message "Switching to branch: release/#{params[:version_number]}"
        branch = "release/#{params[:version_number]}"

        sh "git add . && git commit -m \"Release #{params[:version_number]}.\""
        sh "git checkout develop"
        sh "git merge --no-ff #{branch}"

        sh "git checkout master"
        sh "git merge --no-ff develop"
        sh "git tag -a \"#{params[:version_number]}\"  -m \"Release #{params[:version_number]}\""

        sh "git branch -d #{branch}"
        sh "git push --all"
        sh "git push -v origin refs/tags/#{params[:version_number]}"
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "A short description with <= 80 characters of what this action does"
      end

      def self.details
        "Use this action  to create a new release branch as per https://nvie.com/posts/a-successful-git-branching-model/."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :version_number,
                                       env_name: "FL_VERSION_NUMBER_VERSION_NUMBER",
                                       description: "Creates release branch to a specific version",
                                       optional: false),
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        [
          # ['VERSION_NUMBER', 'A description of what this value contains']
        ]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.authors
        ["https://github.com/joseprl89"]
      end

      def self.is_supported?(platform)
        # you can do things like
        #
        #  true
        #
        #  platform == :ios
        #
        #  [:ios, :mac].include?(platform)
        #
        true
      end
    end
  end
end
