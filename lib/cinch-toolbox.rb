# -*- coding: utf-8 -*-
require 'cinch-toolbox/version'
require 'open-uri'
require 'patron'
require 'nokogiri'

module Cinch
  module Toolbox
    # Get an element of the supplied website
    def Toolbox.get_html_element(url, selector, mode = 'css')
      # Make sure the URL is legit
      url = URI::extract(url, ["http", "https"]).first

      case mode
      when 'css'
        return Nokogiri::HTML(open(url)).css(selector).first.content
      when 'xpath'
        return Nokogiri::HTML(open(url)).xpath(selector).first
      end
    end

    # Expand a previously shortened URL via the configured shortener
    def Toolbox.expand(url)
      shortener.get("forward.php?format=simple&shorturl=#{url}").body
    end

    # Shorten a URL via the configured shortener
    def Toolbox.shorten(url)
      return url if url.length < 45
      return shortener.get("create.php?format=simple&url=#{url}").body
    end

    # Truncate a given block of text, used for making sure the bot doesn't flood.
    def Toolbox.truncate(text, length = 250)
      text = text.gsub(/\n/, ' · ')
      if text.length > length
        text = text[0,length - 1] + '...'
      end
      return text
    end

    # Used to render a period of time in a uniform string.
    # There is probably a much better way to do this, so FIXME
    def Toolbox.time_format(secs)
      data = time_parse(secs)
      string = ''

      string << "#{data[:days]}d "  unless data[:days].zero?  && string == ''
      string << "#{data[:hours]}h " unless data[:hours].zero? && string == ''
      string << "#{data[:mins]}m "  unless data[:mins].zero?  && string == ''
      string << "#{data[:secs]}s"

      return string
    end

    def Toolbox.time_parse(secs)
      days = secs / 86400
      hours = (secs % 86400) / 3600
      mins = (secs % 3600) / 60
      secs = secs % 60

      return { :days => days.floor,
               :hours => hours.floor,
               :mins => mins.floor,
               :secs => secs.floor }
    end

    private

    def Toolbox.shortener
      short = Patron::Session.new
      short.base_url = 'http://is.gd/'
      return short
    end

    def Toolbox.get_page_title(url)
      # Make sure the URL is legit
      url = URI::extract(url, ["http", "https"]).first

      # If the link is to an image, extract the filename.
      if url.match(/\.jpg|jpeg|gif|png$/)
        # unless it's from reddit, then change the url to the gallery to get the image's caption.
        if url.match(/https?:\/\/i\.imgur\.com.+\/([A-Za-z0-9]+)\.(jpg|jpeg|png|gif)/)
          imgur_id = url.match(/https?:\/\/i\.imgur\.com.+\/([A-Za-z0-9]+)\.(jpg|jpeg|png|gif)/)[1]
          url = "http://imgur.com/#{imgur_id}"
        else
          site = url.match(/\.([^\.]+\.[^\/]+)/)
          return site.nil? ? "Image [#{url}]!!!" : "Image from #{site[1]}"
        end
      end

      # Grab the element, return nothing if  the site doesn't have a title.
      debug "URL: #{url}"
      page = Nokogiri::HTML(open(url)).css('title')
      return page.first.content.strip.gsub(/\s+/, ' ') unless page.empty?
    end
  end
end
