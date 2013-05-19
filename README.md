# Cinch Toolbox

This is just a gem required fro many of my plugins, it facilitates a variety of mundane operations.

* URL Shortening / Expansion.
* URL Title Scraping.
* Webpage DOM element retrieval (via xpath or css selectors).
* Output truncation for sanity proof channel output.

Note: There is a small monkey patch to OpenURI contained in this gem. It allows for redirection
on urls that require https. For example, normally if you link to an `http://github.com/...` url on
GitHub you will get redirected to the https version of that link, and OpenURI will lose it's shit.

Note that this *only* honors redirection requests from HTTP => HTTPS and *not* HTTPS => HTTP.


## Installation

Add this line to your application's Gemfile:

    gem 'cinch-toolbox'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cinch-toolbox

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
