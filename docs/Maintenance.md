# Maintenance

This document details some of the regular maintenance tasks we are to perform on the project to keep up to date with dependencies.

## Update Swift

Steps:

* Use Xcode's migration tool to migrate the codebase onto the latest Swift.
* Do the same on the SampleApp project
* Run all tests: `fastlane all_tests`
* Update CocoaPods specs to use the right Swift version
* Perform a [release](Releasing.md).
