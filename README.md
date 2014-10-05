# Platform API

Ruby HTTP client for the Heroku API.

## Installation

Add this line to your application's Gemfile:

```
gem 'platform-api'
```

And then execute:

```
bundle
```

Or install it yourself as:

```
gem install platform-api
```

### Get Setup with your Heroku Token

The first thing you need is a client setup with an OAuth token.  You can create an OAuth token using the `heroku-oauth` toolbelt plugin:

```bash
$ heroku plugins:install git@github.com:heroku/heroku-oauth.git
$ heroku authorizations:create -d "Platform API example token"
Created OAuth authorization.
  ID:          2f01aac0-e9d3-4773-af4e-3e510aa006ca
  Description: Platform API example token
  Scope:       global
  Token:       e7dd6ad7-3c6a-411e-a2be-c9fe52ac7ed2
```

Use the `Token` value when instantiating a client:

```ruby
require 'platform-api'
heroku = PlatformAPI.connect_oauth('e7dd6ad7-3c6a-411e-a2be-c9fe52ac7ed2')
```

### Grab info from your Heroku App

We can read the same information back with the `info` method.

```ruby
heroku.app.info('floating-retreat-4255')
=> {"id"=>22979756,
    "name"=>"floating-retreat-4255",
    "dynos"=>0,
    "workers"=>0,
    "repo_size"=>nil,
    "slug_size"=>nil,
    "stack"=>"cedar",
    "requested_stack"=>nil,
    "create_status"=>"complete",
    "repo_migrate_status"=>"complete",
    "owner_delinquent"=>false,
    "owner_email"=>"jkakar@heroku.com",
    "owner_name"=>nil,
    "domain_name"=>
     {"id"=>nil,
      "app_id"=>22979756,
      "domain"=>"floating-retreat-4255.herokuapp.com",
      "base_domain"=>"herokuapp.com",
      "created_at"=>nil,
      "default"=>true,
      "updated_at"=>nil},
    "web_url"=>"http://floating-retreat-4255.herokuapp.com/",
    "git_url"=>"git@heroku.com:floating-retreat-4255.git",
    "buildpack_provided_description"=>nil,
    "region"=>"us",
    "created_at"=>"2014/03/12 16:44:09 -0700",
    "archived_at"=>nil,
    "released_at"=>"2014/03/12 16:44:12 -0700",
    "updated_at"=>"2014/03/12 16:44:12 -0700"}
```

### Scaling Heroku Applications

Lets scale the  `web` dyno to 4 processes dyno and `worker` processes to 2 at twice the power (2X).

```ruby
import platform-api
topology = [
  Dyno.new(Worker, 2, '2X'), Dyno.new(Web, 4)
]
puts Topology.scale('floating-retreat-4255', topology)
=> {"command"=>"bundle exec rails server -p $PORT -e development", "created_at"=>"2014-05-24T13:49:34Z", "id"=>"dfc7dd7e-5724-4d98-a07d-814621dd7e61", "type"=>"web", "quantity"=>4, "size"=>"1X", "updated_at"=>"2014-10-05T18:56:42Z"}
{"command"=>"bundle exec rake jobs:work", "created_at"=>"2014-05-24T13:49:34Z", "id"=>"c32796ce-c7ac-4d10-9446-7725601645df", "type"=>"worker", "quantity"=>2, "size"=>"2X", "updated_at"=>"2014-10-05T18:56:42Z"}
```

### Add/Modify Config Variables

Just pass in a hash with your app name to set/modify a configuration variable.

```ruby
heroku.config_var.update('floating-retreat-4255', {'MYAPP' => 'ROCKS'})
=> {"HEROKU_POSTGRESQL_COBALT_URL"=>"postgres://<redacted>",
    "MYAPP"=>"ROCKS"}
```


Hopefully this has given you a taste of how the client works.  If you have
questions please feel free to file issues.

### Debugging

Sometimes it helps to see more information about the requests flying by.  You
can start your program or an `irb` session with the `EXCON_DEBUG=1`
environment variable to cause request and response data to be written to
`STDERR`.

### Passing custom headers

The various `connect` methods take an options hash that you can use to include
custom headers to include with every request:

```ruby
client = PlatformAPI.connect('my-api-key', default_headers: {'Foo' => 'Bar'})
```

### Using a custom cache

By default, the `platform-api` will cache data in `~/.heroics/platform-api`.
Use a different caching by passing in the [Moneta](https://github.com/minad/moneta)
instance you want to use:

```ruby
client = PlatformAPI.connect('my-api-key', cache: Moneta.new(:Memory))
```

### Connecting to a different host

Connect to a different host by passing a `url` option:

```ruby
client = PlatformAPI.connect('my-api-key', url: 'https://api.example.com')
```
