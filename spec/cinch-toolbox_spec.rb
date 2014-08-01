require 'spec_helper'
require 'fakeweb'

describe Cinch::Toolbox do

  describe 'the get_html_element method' do
    before(:all) do
      @fake_web_html = "<div id=\"a1\" class=\"top\">\n<div class=\"foo\">Bar</div>\n<div id=\"foo1\">Baz</div>\n</div>"
      FakeWeb.register_uri( :get, "http://example.com/",
                            :body => @fake_web_html)
    end

    it 'should return a string with contents of a css selector of a web page' do
      element = Cinch::Toolbox.get_html_element('http://example.com/', '.foo', :css)
      expect(element).to eq('Bar')
    end

    it 'should return a string with full markup of a css selector of a web page' do
      element = Cinch::Toolbox.get_html_element('http://example.com/', '.top', :css_full)
      expect(element).to eq(@fake_web_html)
    end

    it 'should return a string with contents of a xpath selector of a web page' do
      element = Cinch::Toolbox.get_html_element('http://example.com/', "//div/div[1]", :xpath)
      expect(element).to eq('Bar')
    end

    it 'should return a string with contents of a xpath selector of a web page' do
      element = Cinch::Toolbox.get_html_element('http://example.com/', "//div[@id='a1']", :xpath_full)
      expect(element).to eq(@fake_web_html)
    end

    it 'should return nil if the css element does not exist' do
      element = Cinch::Toolbox.get_html_element('http://example.com/', '.foo2', :css)
      expect(element).to be_nil
    end

    it 'should return nil if the xpath element does not exist' do
      element = Cinch::Toolbox.get_html_element('http://example.com/', "//div/div[3]", :xpath)
      expect(element).to be_nil
    end

    it 'should return nil if there is a problem finding the site' do
      element = Cinch::Toolbox.get_html_element('http://baddurl.com/', '.foo2', :css)
      expect(element).to be_nil
    end

    it 'should return the page title if there is a http => https trasition' do
      element = Cinch::Toolbox.get_html_element('http://github.com/bhaberer/', 'title', :css)
      expect(element).to include('bhaberer (Brian Haberer)')
    end

    it 'should return nil if there is a https => http trasition' do
      element = Cinch::Toolbox.get_html_element('https://www.amazon.com/', 'title', :css)
      expect(element).to be_nil
    end
  end

  describe 'the get_page_title method' do
    it 'should return a page title for a given url' do
      FakeWeb.register_uri( :get, 'http://example.com/',
                            body: '<body><title>Page Title</title></body>')
      element = Cinch::Toolbox.get_page_title('http://example.com/')
      expect(element).to eq('Page Title')
    end

    it 'should return Nil if a page is lacking a title' do
      FakeWeb.register_uri( :get, "http://example.com/", body: '<body>Page Title</body>')
      element = Cinch::Toolbox.get_page_title('http://example.com/')
      expect(element).to be_nil
    end

    it 'should return an image title if a page is a supported image type' do
      [:jpg, :jpeg, :gif, :png].each do |image|
        img = Cinch::Toolbox.get_page_title("http://example.com/image.#{image}")
        expect(img).to eq('Image from http://example.com')
      end
    end

    it 'should return Nil if a page is lacking a title' do
      element = Cinch::Toolbox.get_page_title("http://i.imgur.com/oMndYK7.jpg")
      expect(element).to eq('Anybody with a cat will relate. - Imgur')
    end
  end

  describe 'url shortening and expanding' do
    it 'should shorten long urls' do
      url = Cinch::Toolbox.shorten('http://en.wikipedia.org/wiki/Llanfairpwllgwyngyllgogerychwyrndrobwllllan')
      expect(url).to eq('http://is.gd/PaUTII')
    end

    it 'should not shorten urls that are already short enough (< 45 cha)' do
      url = Cinch::Toolbox.shorten('http://en.wikipedia.org/')
      expect(url).to eq('http://en.wikipedia.org/')
    end

    it 'should be able to expand shortened links' do
      url = 'http://en.wikipedia.org/wiki/Llanfairpwllgwyngyll'
      expect(url).to eq(Cinch::Toolbox.expand(Cinch::Toolbox.shorten(url)))
    end
  end

  describe 'truncate method' do
    it 'should truncate text past the limit' do
      foo = String.new
      1000.times { foo << 'a' }
      expect(Cinch::Toolbox.truncate(foo).length).to eq(250)
    end

    it 'should not truncate text within limit' do
      foo = String.new
      1000.times { foo << 'a' }
      expect(Cinch::Toolbox.truncate(foo, 100).length).to eq(100)
    end
  end

  describe 'time parseing' do
    it 'should parse seconds into a user friendly string' do
      expect(Cinch::Toolbox.time_format(126))
        .to eq('2 mins, 6 seconds')
    end

    it 'should allow users to limit the kinds of units returned' do
      expect(Cinch::Toolbox.time_format(126020, [:days, :seconds]))
        .to eq('1 days, 20 seconds')
    end

    it 'should allow users to specify short form' do
      expect(Cinch::Toolbox.time_format(126000, [:days], :short))
        .to eq('1d')
    end
  end
end
