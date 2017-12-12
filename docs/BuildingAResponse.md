This section details all the customizations you can perform to a request. Notice that you can also see them in action in our [acceptance tests](MockURLResponderTests/MockURLResponderAcceptanceTests.swift)

# Filtering when to respond

In this section we describe how you can customise when to use a given response.

## By host

In order to specify which host we are mocking, we hvae to create a MockURLResponderConfigurator specifying the scheme and host:

`let configurator = MockURLResponderConfigurator(scheme: "https", host: "www.w3.org")`

The configurator allows us to install stubs for certain network calls with great flexibility. An example of a setup is:

```
let configurator = MockURLResponderConfigurator(scheme: "https", host: "www.w3.org")

configurator.respond(to: "/path")
    .with(body: body)
    .once()

MockURLResponder.setUp(with: configurator.arguments)
```

Notice that all responses must specify how many times it will be repeated. [More info here](#multiple-responses-same-request).

## By query value

Use the method `when(value: ..., forQueryField: ...)` in order to specify a response only when that value is present. More than one key value pairs can be specified if the method is called multiple times. For instance, when mocking a search for a topic named `topic`, the following response would be received:

```
configurator.respond(to: "/path")
    .when(value: "topic", forQueryField: "q")
    .with(body: "Found")
    .once()
```

## By header fields

Use the method `when(value: ..., forHeaderField: ...)` in order to specify a response only when that value is present. More than one key value pairs can be specified if the method is called multiple times.

For instance, this response will only be returned if the user is logged in with a token with value `token`, which is passed in a header named `X-Authorization-Id`.

```
configurator.respond(to: "/path")
    .when(value: "token", forHeaderField: "X-Authorization-Id")
    .with(body: "With token")
    .once()
```

# Building a Response

In this section we describe how you can customise the response mocked.

## respond(to: ..., method: ...)

Generates a response builder to further customise.

```
configurator.respond(to: "/path", method: "GET")
```

## with(body: ...)

This method allows to set the body that will be injected into the request. Can be used by doing:

```
configurator.respond(to: "/path", method: "GET")
    .with(body: "Hi!")
    .once()
```

## with(bodyFromURL: ...)

Allows to pass in a url to set the body contents. Could use a host that has not been mocked, or a data:// schema, or a local file.

```
configurator.respond(to: "/path", method: "GET")
    .with(bodyFromURL: URL(string: "http://www.google.com/")
    .once()
```

## with(resource: ..., ofType: ..., directory: ..., localization: ..., bundle: ...)

Allows to load a resource from the bundle and pass it as a body in the response.

```
configurator.respond(to: "/path", method: "GET")
    .with(resource: "test", ofType: "json", bundle: Bundle(for: MockURLResponderAcceptanceTests.self))
    .once()
```

## with(status: ...)

Allows to specify the HTTP status code to pass in the response.

```
configurator.respond(to: "/path", method: "GET")
    .with(status: 401)
    .once()
```

## with(value: ..., forHeaderField: ...) 

Sets a header in the mocked response.

```
configurator.respond(to: "/path", method: "GET")
    .with(value: "a57a1c80a29205ab743a37fc7ea1201b", forHeaderField: "Set-Cookie")
    .once()
```

## withDroppedRequest()

Drops the request. Useful when testing recoverability. In the following example, the call will be dropped once, but the second retry will succeed.

```
configurator.respond(to: "/path", method: "GET")
    .withDroppedRequest()
    .once()

configurator.respond(to: "/path", method: "GET")
    .with(body: "Hi!")
    .once()
```

## with(delay: ...)

Delays the response for as many seconds as specified in the parameter, passed as a TimeInterval (double). Useful when testing that a loading spinner appears.

```
configurator.respond(to: "/path", method: "GET")
    .with(body: "Hi!")
    .once()
```

# Multiple Responses Same Request

It is mandatory to specify how many times a response should be executed. We provide three methods to do so:

## once()

Uses the response once.

```
configurator.respond(to: "/path", method: "GET")
    .with(body: "Hi!")
    .with(delay: 10) // seconds
    .once()
```

## always()

Always uses the response. Technically, it stops at Int.max repetitions.

```
configurator.respond(to: "/path", method: "GET")
    .with(body: "Hi!")
    .always()
```

## times(...)

Repeats the call as many times as specified in the parameter.

```
configurator.respond(to: "/path", method: "GET")
    .with(body: "Hi!")
    .times(5)
```
