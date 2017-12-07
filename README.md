# MockURLResponder
An iOS network mocking DSL library with minimal setup required. Working also with **UITests**.  
Fork from: [https://github.com/joseprl89/MockURLResponder](https://github.com/joseprl89/MockURLResponder)

# See it in action

The goal of this library is to provide a very simple way to mock the network calls your app performs, in a very unobtrusive way. As an example, you could setup what each UI test executes by using something similar to the following snippet:

```
let configurator = MockURLResponderConfigurator(scheme: "https", host: "api.myawesomeapp.com")

configurator.respond(to: "/path/to/resource", method: "GET")
	.with(body: "{ \"json\": 123 }")
	.always()

let application = XCUIApplication()
application.launchArguments = ["-MyCustomArgument"] + configurator.arguments + configuratorTwo.arguments
application.launch()
```

# Getting started

## Installation with Cocoapods
```
pod 'MockURLResponder', :git => 'https://github.com/TheAdamBorek/MockURLResponder', :tag => '0.2.4'
pod 'MockURLResponderTestAPI', :git => 'https://github.com/TheAdamBorek/MockURLResponder', :tag => '0.2.4'
```

This will compile two schemes of the library:

1. MockURLResponder
2. MockURLResponderTestAPI

The first one provides the mocking capabilities on the target that requires its network calls mocked.
The second one, will provide a DSL to generate launch arguments the first one consumes in order to configure the responses. Notice that this framework depends on the first one, so both frameworks will have to be embedded into the test targets.

Usually, this will mean that you embed `MockURLResponder` into your app's target, and `MockURLResponderTestAPI` onto your UI tests targets.

Once you have the built frameworks, drag and drop them into the targets that are going to use them.

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
