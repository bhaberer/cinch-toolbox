# Cinch Toolbox

[![Gem Version](https://badge.fury.io/rb/cinch-toolbox.png)](http://badge.fury.io/rb/cinch-dicebag)
[![Dependency Status](https://gemnasium.com/bhaberer/cinch-toolbox.png)](https://gemnasium.com/bhaberer/cinch-dicebag)
[![Build Status](https://travis-ci.org/bhaberer/cinch-toolbox.png?branch=master)](https://travis-ci.org/bhaberer/cinch-dicebag)
[![Coverage Status](https://coveralls.io/repos/bhaberer/cinch-toolbox/badge.png?branch=master)](https://coveralls.io/r/bhaberer/cinch-dicebag?branch=master)
[![Code Climate](https://codeclimate.com/github/bhaberer/cinch-toolbox.png)](https://codeclimate.com/github/bhaberer/cinch-dicebag)

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

    gem 'cinch/toolbox'

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

## Changelog

* 1.0.2
    * [Enhancement] Reorged the file layout a bit to be more canonical (`require cinch/toolbox`
        now instead of `require cinch-toolbox`.
    * [Enhancement] Added support for retrieving the full contents of a html element by passing
        `:css_full` or `:xpath_full` to the `Cinch::Toolbox.get_html_element` method.
* 1.0.1
    * [Refactor] Updated how `time_format` functions.
* 1.0.0 (
    * Added tests!
    * Added docs!
    * Cleaned up code in `Toolbox.get_html_element` to be more error resistant
    * Cleaned up code in `Toolbox.time_format` to be more concise.

