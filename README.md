# URITemplate - a uri template library

With URITemplate you can generate URIs based on templates.
The template syntax is defined by the [RFC 6570]( http://tools.ietf.org/html/rfc6570 ) spec.

This shard supports expansion and partial expansion (but not extraction).

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     uri_template:
       github: nanobowers/uri_template
   ```
   
2. Run `shards install`

## Usage

```crystal
require "uri_template"

tpl = URITemplate.new("http://{host}{/segments*}/{file}{.extensions*}")

# This will fuly expand the template:
tpl.expand(host: "www.host.com", segments: ["path","to","a"], file: "file", extensions: ["x","y"])
# => "http://www.host.com/path/to/a/file.x.y"

# This will give a new uri template with just the host expanded:
tpl.expand_partial(host: "www.host.com")
# => <URITemplate::Template:0x7fb7e1bb1e40 ...> 
```

### Keyword or Hash Arguments
`expand` and `expand_partial` can accept either keyword arguments or a Hash argument, or both. Keyword arguments have precedence over the hash argument.


### Template vs URITemplate
The `URITemplate` module has several convenience module methods that create an instance of `URITemplate::Template` and then peform an operation on at constructed object (e.g. `expand`, `expand_partial`, `variables`, etc.)  Depending on the use model it may be more convenient or efficient to use the underlying URITemplate::Template class.

```crystal
# equivalent approaches:
URITemplate::Template.new("{variable}").expand(variable: "value")
URITemplate.expand("{variable}", variable: "value")
```

## RFC 6570 Syntax

The syntax defined by [RFC 6570]( http://tools.ietf.org/html/rfc6570 ) has lots of features.
Generally, anything surrounded by curly brackets is interpreted as variable.

```crystal
URITemplate.new("{variable}").expand(variable: "value")
# => "value"
```

The way variables are inserted can be modified using operators. The operator is the first character between the curly brackets. There are seven operators de
fined `#`, `+`, `;`, `?`, `&`, `/` and `.`. So if you want to create a form-style query do this:

```crystal
URITemplate.new("{?variable}").expand(variable: "value")
# => "?variable=value"
```

## Testing

This passes the rfc6570 test-suite provied by the `uritemplate-test` suite which is included as a git submodule and used by other uritemplate packages for other programming languages.  In addition to those tests, there are quite a few additional tests which are inspired by tests in some popular Ruby gems and Python packages.  Please feel free to write some more tests and submit a PR.

```sh
git submodule init
git submodule update
crystal spec
```

## Contributing

1. Fork it (<https://github.com/your-github-user/uri_template/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Ben Bowers](https://github.com/nanobowers) - creator and maintainer

## License

[MIT License](LICENSE)

Note that the included `uritemplate-test` submodule is Apache v2.0 licensed.
