# Maintenance

This document details some of the regular maintenance tasks we are to perform on the project to keep up to date with dependencies.

## Update Swift

Use Xcode's migration tool to migrate the codebase onto the latest Swift.

Run all tests to ensure the operation is successful:

```bash
fastlane all_tests
```

Once done, use the fastlane release lane to create a new release using the new Swift version.
