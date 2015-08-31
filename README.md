# dozens_jp_cli

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dozens_jp_cli'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install dozens_jp_cli

## Usage


```ruby 
require 'dozens_jp_cli'


dozens_user_id = "youname"
dozens_user_token = "xxxxxxxxxxxxxxxxxx"

d = Dozens.new(dozens_user_id,dozens_user_token)

## create new zone
ret = d.zone_create_new("dns.example.com", "webmaster@dns.example.com")
## delete a zone 
ret = d.zone_delete("dns.example.com")
## add a record into zone
ret = d.record_create("www.dns.example.com","dns.example.com")
## or 
ret = d.record_create("www","dns.example.com")
## delete a record 
ret = d.record_delete("www.dns.example.com")

```



## Contributing

1. Fork it ( https://github.com/[my-github-username]/dozens_jp_cli/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request



