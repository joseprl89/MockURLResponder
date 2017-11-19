# Building a Response

This section details all the customizations you can perform to a request. Notice that you can also see them in action in our [acceptance tests](MockURLResponderTests/MockURLResponderAcceptanceTests.swift)

All code samples assume that you already have a `MockURLResponderConfigurator` setup, which can be created by using:

`let configurator = MockURLResponderConfigurator(scheme: "https", host: "www.w3.org")`

Notice that all responses must specify how many times it will be repeated. [More info here](#multiple-responses-same-request).

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
