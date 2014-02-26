# -*- coding: utf-8 -*-
require 'cinch/toolbox/version'
require 'open-uri'
require 'patron'
require 'nokogiri'
require 'net/http'
require 'uri'

module Cinch
  # Module for conveniance methods used in multiple Cinch plugins.
  module Toolbox
    # Get an element of the supplied website
    # @param [String] url The url to access.
    # @param [String] selector The the selector to try an acquire on the page.
    # @param [String] mode (:css) Set this to the kind of selection you want to
    #   do.
    # @option [String] :mode :css Fetch just the text content at the css
    #   selector.
    # @option [String] :mode :css_full Fetch the markup and text content at
    #   the css selector.
    # @option [String] :mode :xpath Fetch just the text content at the
    #   xpath selector.
    # @option [String] :mode :xpath_full Fetch the markup and text at the
    #   xpath selector.
    # @return [String] The content ofg the Element or Nil if the element
    #   could not be found.
    def self.get_html_element(url, selector, mode = :css)
      # Make sure the URL is legit
      url = Nokogiri.HTML(open(extract_url(url)))

      case mode
      when :css, :xpath
        page = url.send(mode.to_sym, selector)
        page.first.content unless page.first.nil?
      when :css_full, :xpath_full
        url.send("at_#{mode.to_s.gsub(/_full/, '')}", selector).to_html
      end
    # Rescue for any kind of network sillyness
    rescue SocketError, RuntimeError, Net::HTTPError
      nil
    end

    # Get the title of a given web page.
    # @param [String] url The url of the page you want the title from.
    # @return [String] Either contents of the title element or a notion
    #   for an image.
    def self.get_page_title(url)
      # Make sure the URL is legit
      url = extract_url(url)

      if url.match(/([^\s]+(\.(?i)(jpe?g|png|gif|bmp))$)/)
        # If the link is to an image, extract the filename.
        title = get_image_title(url)
      else
        # Grab the element, return nothing if  the site doesn't have a title.
        title = Toolbox.get_html_element(url, 'title')
      end
      title.strip.gsub(/\s+/, ' ') unless title.nil?
    end

    # Shorten a URL via the configured shortener
    # @param [String] url The url of the page you want to shorten.
    # @return [String] The shortened url.
    def self.shorten(url)
      return url if url.length < 45
      uri = URI.parse("http://is.gd/create.php?format=simple&url=#{url}")
      shortened = Net::HTTP.get(uri)
      shortened if shortened.match(%r(https?://is.gd/))
    end

    # Expand a previously shortened URL via the configured shortener
    # @param [String] url A previously shortened url.
    # @return [String] The expanded url.
    def self.expand(url)
      uri = URI.parse("http://is.gd/forward.php?format=simple&shorturl=#{url}")
      unshortened = Net::HTTP.get(uri)
      unshortened unless unshortened.match(%r(https?://is.gd/))
    end

    # Truncate a given block of text, used for making sure the bot doesn't
    #   flood.
    # @param [String] text The block of text to check.
    # @param [Fixnum] length (250) length to which to constrain the
    #   block of text.
    def self.truncate(text, length = 250)
      text = text.gsub(/\n/, '  ')
      text = text[0, (length - 3)] + '...' if text.length > length
      text
    end

    # Simple check to make sure people are using a command via the main channel
    #   for plugins that require a channel for context.
    def self.sent_via_private_message?(m, error = nil)
      return false unless m.channel.nil?
      error = 'You must use that command in the main channel.' if error.nil?
      m.user.msg error
      true
    end

    # Used to render a period of time in a uniform string.
    # There is probably a much better way to do this
    # @param [Fixnum] secs Number of seconds to render into a string.
    def self.time_format(secs, units = nil, format = :long)
      time = build_time_hash(secs, units)
      parse_time_hash(time, format)
    end

    # Extract the first url from a string
    # @param [String] url String to parse URIs from.
    # @return [URI] URI created from the url.
    def self.extract_url(url)
      extract_urls(url).first
    end

    # Extract the urls from a string
    # @param [String] url String to parse URIs from.
    # @return [Array] List of URIs created from the string.
    def self.extract_urls(url)
      URI.extract(url, %w(http https))
    end

    private

    def self.get_image_title(url)
      if url.match(/imgur/)
        # Get the page title if it's imgur
        imgur_image_title(url)
      else
        site = url[/([^\.]+\.[^\/]+)/, 1]
        site.nil? ? "Image [#{url}]" : "Image from #{site}"
      end
    end

    def self.imgur_image_title(url)
      imgur_id = url[%r(https?://i\.imgur\.com.*/(\w+)\.(\D{3,4})), 1]
      url = "http://imgur.com/#{imgur_id}"
      Toolbox.get_html_element(url, 'title')
    end

    def self.build_time_hash(secs, units)
      { days:     (secs / 86_400).floor,
        hours:   ((secs % 86_400) / 3600).floor,
        mins:    ((secs % 3_600)  / 60).floor,
        seconds:  (secs % 60).floor }
        .delete_if { |period, _time| units && !units.include?(period) }
    end

    def self.parse_time_hash(times, format)
      string = []
      times.each_pair do |period, time|
        if period == :seconds || !(time.zero? && string.empty?)
          string << [time, format == :long ? " #{period}" : period.slice(0)]
                      .join
        end
      end
      string.join(', ')
    end
  end
end

# Patch OpenURI to allow for redirection from http => https
module OpenURI
  def self.redirectable?(uri1, uri2) # :nodoc:
    uri1.scheme.downcase == uri2.scheme.downcase ||
    /\A(?:http|ftp)\z/i =~ uri1.scheme &&
    /\A(?:http|ftp|https)\z/i =~ uri2.scheme
  end
end
