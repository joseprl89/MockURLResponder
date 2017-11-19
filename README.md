# MockURLResponder

[![BuddyBuild](https://dashboard.buddybuild.com/api/statusImage?appID=5a11c0d7ec4ba100010e5a4f&branch=master&build=latest)](https://dashboard.buddybuild.com/apps/5a11c0d7ec4ba100010e5a4f/build/latest?branch=master) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

An iOS network mocking DSL library with minimal setup required.

# Getting started

## Installation with Carthage

The basic setup of Carthage can be found [here](https://github.com/Carthage/Carthage). For this specific project, add to your Cartfile the following line:

```github "joseprl89/MockURLResponder"```

This will compile two schemes of the library:

1. MockURLResponder
2. MockURLResponderTestAPI

The first one provides the mocking capabilities on the target that requires its network calls mocked.
The second one, will provide a DSL to generate launch arguments the first one consumes in order to configure the responses. Notice that this framework depends on the first one, so both frameworks will have to be embedded into the test targets.

Usually, this will mean that you embed `MockURLResponder` into your app's target, and `MockURLResponderTestAPI` onto your UI tests targets.

Once you have the built frameworks, drag and drop them into the targets that are going to use them.

### Image not found in app target

If you encounter the image not found in the app target, go to `Project` > `App Target` > `General` tab and add the framework in the `Embedded binaries` box.

This is related to [this issue](https://github.com/Carthage/Carthage/issues/635)

### Image not found in test target

Follow the instructions [here](http://www.mokacoding.com/blog/setting-up-testing-libraries-with-carthage-xcode7/). In the sample app, it meant adding to the `Build phases` a bash script running:

```
/usr/local/bin/carthage copy-frameworks
```

Using as input:

`$(PROJECT_DIR)/Carthage/Build/iOS/MockURLResponderTestAPI.framework`
`$(PROJECT_DIR)/Carthage/Build/iOS/MockURLResponder.framework`

This is related to [this issue](https://github.com/Carthage/Carthage/issues/635)

**Cocoapods is not supported. PRs welcome.**

# Usage

The framework is split into two separate components to ensure that we can decouple our subject under test (SUT) from our test code which injects the expected responses.

## Usage of Subject Under Test (SUT)

The subject under test has a very slim integration with MockURLResponder, which is basically reduced to execute:

```MockURLResponder.setUp()```

This will will read the ProcessInfo launchArguments to configure the mocked responses, and then register a `URLProtocol` in the shared URLSession that will intercept network calls and respond as configured.

It allows to customise the behaviour of the system when finding a call that has not been mocked by setting `MockURLResponder.Configuration.mockingBehaviour`. The values it can take are:

1. preventNonMockedNetworkCalls: The default value. Upon finding a network call that hasn't been mocked, `fatalError()s` your application. Consider it a strict mock instead of a partial mock.
2. dropNonMockedNetworkCalls: Drops the network call and returns an error.
3. allowNonMockedNetworkCalls: Allows non mocked calls to hit the network. Tread carefully, since this makes your tests slower and unreliable.

## Custom URLSessions

If you are using a custom url session, then make sure to add the MockURLProtocol class in the list of url protocols used by your custom URLSession. This can be done as:

```
var customConfiguration = URLSessionConfiguration()
// your setup
// ...
customConfiguration.protocolClasses = [MockURLProtocol.self]
URLSession(configuration: customConfiguration)
```

## Usage from UI Tests

As mentioned earlier, the test code will inject into the SUT the mocked responses via its launch arguments. This will integrate painlessly with Xcode UITests.

Namely, the integration starts by creating an instance (or more) of `MockURLResponderConfigurator`:

`let configurator = MockURLResponderConfigurator(scheme: "https", host: "www.google.com")`

Once the configurator for a host is created, you can configure responses to one or more resources by using the respond method, which returns a response builder that can be further customised:

```
configurator.respond(to: "/", method: "GET")
	.with(body: "Mock URL Responder is great!")
	.always()
```

The builder allows to customise in detail the behaviour of the response. This is explained in detail in the [Building a response](/docs/BuildingAResponse.md)

Notice that as a last step of the response customisation there must always be a call to how many times the call must be mocked. This can be either of:

1. `once()`
2. `times(N)`
3. `always()`

This will allow you to customise a sequence of multiple responses for the same resource.

Finally, you have to pass this configuration into the SUT. This is done by injecting the arguments it generates via the `XCUIApplication` launchArguments. As an advanced example, the following code would register multiple configurators that have been setup separetely, plus custom arguments your app may be using:

```
let application = XCUIApplication()
application.launchArguments = ["-MyCustomArgument"] + configurator.arguments + configuratorTwo.arguments
application.launch()
```

## Usage from Unit Tests

Since the components of the framework are decoupled, they will allow to be used from within unit tests as well. The usage is quite similar to that of UITests, only it doesn't rely on the app delegate to setup the MockURLResponder and does it manually instead.

```
override func tearDown() {
    MockURLResponder.tearDown()
}

func test_mocksSingleCall() {
    let configurator = MockURLResponderConfigurator(scheme: "https", host: "www.w3.org")

    configurator.respond(to: "/path", method: "GET")
        .with(body: body)
       .once()

    MockURLResponder.setUp(with: configurator.arguments)

    XCTAssertEqual(get("https://www.w3.org/path?q=query#fragment"), body)
}
```


# Running the tests

Open the workspace at the root of this repo and run the unit tests in either of the schemes.

# Versioning

We follow [Semantic Versioning](http://semver.org/). Currently we are on a pre v1.0 meaning that breaking changes could be added from one minor to another. To avoid confusion, we will bump patches when performing non breaking changes and minor when we perform breaking changes.

E.g. `0.1.0` is compatible with `0.1.1`, but `0.1.0` may break when upgrading to `0.2.0`.

# Framework philosophy

We started the development of this framework with the goal to provide a dependency with the smallest footprint possible (in terms of size and maintainability), while allowing to easily decouple your project from it.

This would allow consumers to build on top of this framework their own testing solution rather than tightly coupling themselves to a 3rd party solution.
