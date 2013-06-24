# -*- coding: utf-8 -*-
require 'cinch-toolbox/version'
require 'open-uri'
require 'patron'
require 'nokogiri'

module Cinch
  module Toolbox

    # Get an element of the supplied website
    # @param [String] url The url to access.
    # @param [String] selector The the selector to try an acquire on the page.
    # @param [String] mode (:css) Set his to css or xpath based on the type of selector.
    # @return [String] The content ofg the Element or Nil if the element could not be found.
    def Toolbox.get_html_element(url, selector, mode = :css)
      # Make sure the URL is legit
      url = URI::extract(url, ["http", "https"]).first
      url = Nokogiri::HTML(open(url))
      if url.send(mode.to_sym, selector).empty?
        return nil
      else
        return url.send(mode.to_sym, selector).first.content
      end
    rescue SocketError, RuntimeError
      # Rescue for any kind of network sillyness
      return nil
    end

    # Get the title of a given web page.
    # @param [String] url The url of the page you want the title from.
    # @return [String] Either contents of the title element or a notion for an image.
    def Toolbox.get_page_title(url)
      # Make sure the URL is legit
      url = URI::extract(url, ["http", "https"]).first

      # If the link is to an image, extract the filename.
      if url.match(/\.jpg|jpeg|gif|png$/)
        # unless it's from reddit, then change the url to the gallery to get the image's caption.
        if imgur_id = url[/https?:\/\/i\.imgur\.com.*\/([A-Za-z0-9]+)\.(jpg|jpeg|png|gif)/, 1]
          url = "http://imgur.com/#{imgur_id}"
        else
          site = url.match(/([^\.]+\.[^\/]+)/)
          return site.nil? ? "Image [#{url}]!!!" : "Image from #{site[1]}"
        end
      end

      # Grab the element, return nothing if  the site doesn't have a title.
      title = Toolbox.get_html_element(url, 'title')
      return title.strip.gsub(/\s+/, ' ') unless title.nil?
    end

    # Shorten a URL via the configured shortener
    # @param [String] url The url of the page you want to shorten.
    # @return [String] The shortened url.
    def Toolbox.shorten(url)
      return url if url.length < 45
      return shortener.get("create.php?format=simple&url=#{url}").body
    end

    # Expand a previously shortened URL via the configured shortener
    # @param [String] url A previously shortened url.
    # @return [String] The expanded url.
    def Toolbox.expand(url)
      shortener.get("forward.php?format=simple&shorturl=#{url}").body
    end

    # Truncate a given block of text, used for making sure the bot doesn't flood.
    # @param [String] text The block of text to check.
    # @param [Fixnum] length (250) length to which to constrain the block of text.
    def Toolbox.truncate(text, length = 250)
      text = text.gsub(/\n/, '  ')
      if text.length > length
        text = text[0, (length - 3)] + '...'
      end
      return text
    end

    # Used to render a period of time in a uniform string.
    # There is probably a much better way to do this, so FIXME
    # @param [Fixnum] secs Number of seconds to render into a string.
    def Toolbox.time_format(secs, units = nil)
      data = { :days  => (secs / 86400).floor,
               :hours => ((secs % 86400) / 3600).floor,
               :mins  => ((secs % 3600) / 60).floor,
               :secs  => (secs % 60).floor }
      string = []
      data.keys.map do |period|
        if period == :secs || !(data[period].zero? && string.empty?)
          if units.nil? || units.include?(period)
            string << "#{data[period]} #{period}"
          end
        end
      end
      return string.join(', ')
    end

    private

    def Toolbox.shortener
      short = Patron::Session.new
      short.base_url = 'http://is.gd/'
      return short
    end

  end
end

module OpenURI
  def OpenURI.redirectable?(uri1, uri2) # :nodoc:
    uri1.scheme.downcase == uri2.scheme.downcase ||
    (/\A(?:http|ftp)\z/i =~ uri1.scheme && /\A(?:http|ftp|https)\z/i =~ uri2.scheme)
  end
end
