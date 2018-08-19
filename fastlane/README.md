fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios all_tests
```
fastlane ios all_tests
```
Runs the tests for the SDK and sample app.
### ios test_sdk
```
fastlane ios test_sdk
```
Runs the tests for the SDK.
### ios test_sample_app
```
fastlane ios test_sample_app
```
Runs the tests for the Sample App.
### ios release
```
fastlane ios release
```
Performs a release

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
