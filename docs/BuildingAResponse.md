This section details all the customizations you can perform to a request. Notice that you can also see them in action in our [acceptance tests](../MockURLResponderTests/MockURLResponderAcceptanceTests.swift)

# Configuring the request to mock

In this section we describe how you can identify the request that needs to be mocked, specifying which values we can use to configure the mock.

## By host

The first step to configure a mocked response is to specify the host and scheme used by your API. In order to specify to do so, we create a MockURLResponderConfigurator:

`let configurator = MockURLResponderConfigurator(scheme: "https", host: "www.w3.org")`

The configurator is our interface to further customise how the mock server should behave for this specific host. A simple example setup is:

```
let configurator = MockURLResponderConfigurator(scheme: "https", host: "www.w3.org")

configurator.respond(to: "/path")
    .with(body: body)
    .once()

MockURLResponder.setUp(with: configurator.arguments)
```

Notice that all responses must specify how many times it will be repeated. [More info here](#repeating-responses).

## By HTTP Method and path to the resource

The first method we can call on the configurator is `respond(to: ..., method: ...)`. This method will generate a mock response builder to further customise the response we want to do with a set of filters and mocked response values.

```
configurator.respond(to: "/path", method: "GET")
```

## By query value

Use the method `when(value: ..., forQueryField: ...)` in order to specify a response only when that value is present in the HTTP Query. More than one key value pairs can be specified if the method is called multiple times. For instance, the following configuration will respond only if we are to mock a search on the query field `q` for a topic named `topic`:

```
configurator.respond(to: "/path")
    .when(value: "topic", forQueryField: "q")
    .with(body: "Found")
    .once()
```

## By header fields

Use the method `when(value: ..., forHeaderField: ...)` in order to specify a response only when the HTTP header has the value desired. This method can be called multiple times, as many as headers you want to use to identify the request you need to mock.

As an example, this response will only be returned if the user is logged in with a token with value `token`, which is passed in a header named `X-Authorization-Id`.

```
configurator.respond(to: "/path")
    .when(value: "token", forHeaderField: "X-Authorization-Id")
    .with(body: "With token")
    .once()
```

# Building a Response

In this section we describe how you can customise the mocked response with different values.

## Custom HTTP body

The simplest method to provide a mocked body is to simply pass it as a `String`. This is done with the `with(body: ...)` method like so:

```
configurator.respond(to: "/path", method: "GET")
    .with(body: "Hi!")
    .once()
```

If you are interested to use the mock server as a proxy, or want to have some calls passing through, it also allows to request the body contents from a URL. This can be used in a few different ways:

* Can use to proxy to a host that has not been mocked
* Can use the `data://` schema
* Can use the URL of a local file.

An example of this setup:

```
configurator.respond(to: "/path", method: "GET")
    .with(bodyFromURL: URL(string: "http://www.google.com/")
    .once()
```

Finally, we also provide a method to pass the contents of a resource in your bundle using the method `with(resource: ..., ofType: ..., directory: ..., localization: ..., bundle: ...)`:

```
configurator.respond(to: "/path", method: "GET")
    .with(resource: "test", ofType: "json", bundle: Bundle(for: MockURLResponderAcceptanceTests.self))
    .once()
```

## Custom HTTP Status code

The mock server allows to configure the HTTP Status code in the response with the following method:

```
configurator.respond(to: "/path", method: "GET")
    .with(status: 401)
    .once()
```

## Custom HTTP headers

Allows to set a header in the mocked response. Can be called multiple times if multiple header fields are required.

```
configurator.respond(to: "/path", method: "GET")
    .with(value: "a57a1c80a29205ab743a37fc7ea1201b", forHeaderField: "Set-Cookie")
    .once()
```

## Reproducing edge cases

### Mock network failures

Drops the request. Useful when testing how your app recovers from failed network conditions. In the following example, the call will be dropped once, and succeed in the second attempt.

```
configurator.respond(to: "/path", method: "GET")
    .withDroppedRequest()
    .once()

configurator.respond(to: "/path", method: "GET")
    .with(body: "Hi!")
    .once()
```

### Adding a delay

Delays the response for as many seconds as specified in the parameter, passed as a `TimeInterval` (aka double). Useful when testing how the app behaves under slow network conditions.

```
configurator.respond(to: "/path", method: "GET")
    .with(body: "Hi!")
    .with(delay: 10) // seconds
    .once()
```

# Repeating responses

It is mandatory to specify how many times a response should be executed, or otherwise the response configured won't be mocked in the system. Xcode will raise a warning for unused result if you forget to add one of these methods in the configuration.

If the app performs more network calls than expected to a resource, e.g. if you specify once, but the call occurs twice, the following calls will behave as a non mocked network call.

We provide three methods to do so:

## once()

Uses the mocked response just once.

```
configurator.respond(to: "/path", method: "GET")
    .with(body: "Hi!")
    .once()
```

## always()

Always uses the same response, although technically, it stops at Int.max repetitions.

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

# Request matching priority

The requests will be matched in the same order they are configured. This means that the second response will never be provided if you configure your mock like this:

```
configurator.respond(to: "/path", method: "GET")
    .with(body: "First response")
    .always()

configurator.respond(to: "/path", method: "GET")
    .with(body: "Second response")
    .once()
```
