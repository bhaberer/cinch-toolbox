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
      Cinch::Toolbox.get_html_element('http://example.com/', '.foo', :css).
        should == 'Bar'
    end

    it 'should return a string with full markup of a css selector of a web page' do
      Cinch::Toolbox.get_html_element('http://example.com/', '.top', :css_full).
        should == @fake_web_html
    end

    it 'should return a string with contents of a xpath selector of a web page' do
      Cinch::Toolbox.get_html_element('http://example.com/', "//div/div[1]", :xpath).
        should == 'Bar'
    end

    it 'should return a string with contents of a xpath selector of a web page' do
      Cinch::Toolbox.get_html_element('http://example.com/', "//div[@id='a1']", :xpath_full).
        should == @fake_web_html
    end

    it 'should return nil if the css element does not exist' do
      Cinch::Toolbox.get_html_element('http://example.com/', '.foo2', :css).
        should be_nil
    end

    it 'should return nil if the xpath element does not exist' do
      Cinch::Toolbox.get_html_element('http://example.com/', "//div/div[3]", :xpath).
        should be_nil
    end

    it 'should return nil if there is a problem finding the site' do
      Cinch::Toolbox.get_html_element('http://baddurl.com/', '.foo2', :css).
        should be_nil
    end

    it 'should return the page title if there is a http => https trasition' do
      Cinch::Toolbox.get_html_element('http://github.com/bhaberer/', 'title', :css).
        should include 'bhaberer (Brian Haberer)'
    end

    it 'should return nil if there is a https => http trasition' do
      Cinch::Toolbox.get_html_element('https://www.amazon.com/', 'title', :css).
        should be_nil
    end
  end

  describe 'the get_page_title method' do
    before(:all) do
    end

    it 'should return a page title for a given url' do
      FakeWeb.register_uri( :get, "http://example.com/", :body => "<title>Page Title</table>")
      Cinch::Toolbox.get_page_title("http://example.com/").
        should == 'Page Title'
    end

    it 'should return Nil if a page is lacking a title' do
      FakeWeb.register_uri( :get, "http://example.com/", :body => "<body>Page Title</body>")
      Cinch::Toolbox.get_page_title("http://example.com/").
        should be_nil
    end

    it 'should return an image title if a page is a supported image type' do
      [:jpg, :jpeg, :gif, :png].each do |image|
        Cinch::Toolbox.get_page_title("http://example.com/image.#{image}").
          should == "Image from http://example.com"
      end
    end

    it 'should return Nil if a page is lacking a title' do
      Cinch::Toolbox.get_page_title("http://i.imgur.com/oMndYK7.jpg").
        should == "Anybody with a cat will relate. - Imgur"
    end
  end

  describe 'url shortening and expanding' do
    it 'should shorten long urls' do
      Cinch::Toolbox.shorten('http://en.wikipedia.org/wiki/Llanfairpwllgwyngyllgogerychwyrndrobwllllan').
        should == "http://is.gd/PaUTII"
    end

    it 'should not shorten urls that are already short enough (< 45 cha)' do
      Cinch::Toolbox.shorten('http://en.wikipedia.org/').
        should == 'http://en.wikipedia.org/'
    end

    it 'should be able to expand shortened links' do
      url = 'http://en.wikipedia.org/wiki/Llanfairpwllgwyngyll'
      Cinch::Toolbox.expand(Cinch::Toolbox.shorten(url)).should == url
    end
  end

  describe 'truncate method' do
    it 'should truncate text past the limit' do
      foo = String.new
      1000.times { foo << 'a' }
      Cinch::Toolbox.truncate(foo).length.should == 250
    end

    it 'should not truncate text within limit' do
      foo = String.new
      1000.times { foo << 'a' }
      Cinch::Toolbox.truncate(foo, 100).length.should == 100
    end
  end

  describe 'time parseing' do
    it 'should parse seconds into a user friendly string' do
      Cinch::Toolbox.time_format(126).
        should == '2 mins, 6 seconds'
    end

    it 'should allow users to limit the kinds of units returned' do
      Cinch::Toolbox.time_format(126020, [:days, :seconds]).
        should == '1 days, 20 seconds'
    end

    it 'should allow users to specify short form' do
      Cinch::Toolbox.time_format(126000, [:days], :short).
        should == '1d'
    end
  end
end
