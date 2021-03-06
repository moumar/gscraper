require 'spec_helper'
require 'helpers/query'
require 'has_pages_examples'
require 'page_has_results_examples'
require 'has_sponsored_links_examples'
require 'search/page_has_results_examples'

require 'gscraper/search/web_query'

describe GScraper::Search::WebQuery do
  include Helpers

  before(:all) do
    @query = GScraper::Search::WebQuery.new(
      :query => Helpers::DEFAULT_QUERY
    )
    @page = @query.first_page
    @links = @query.sponsored_links
  end

  it_should_behave_like "has Pages"
  it_should_behave_like "Page has Results"
  it_should_behave_like "Page has Search Results"
  it_should_behave_like "has Sponsored Links"

  describe "Search URL" do
    before(:all) do
      @uri = @query.search_url
    end

    it "should be a valid HTTP URI" do
      @uri.class.should == URI::HTTP
    end

    it "should have a default host of www.google.com" do
      @uri.host.should == 'www.google.com'
    end

    it "should allow using alternate hosts" do
      other_host = 'www.google.com.ar'
      other_query = GScraper::Search::WebQuery.new(
        :search_host => other_host,
        :query => Helpers::DEFAULT_QUERY
      )

      other_query.search_url.host.should == other_host
    end

    it "should have a path of /search" do
      @uri.path.should == '/search'
    end

    it "should have a 'q' query-param" do
      @uri.query_params['q'].should == Helpers::DEFAULT_QUERY
    end

    it "should have a 'num' query-param" do
      @uri.query_params['num'].should == @query.results_per_page
    end
  end

  describe "page specific URLs" do
    before(:all) do
      @uri = @query.page_url(2)
    end

    it "should have a 'start' query-param" do
      @uri.query_params['start'].should == @query.results_per_page
    end

    it "should have a 'sa' query-param" do
      @uri.query_params['sa'].should == 'N'
    end
  end

  describe "queries from Web search URLs" do
    before(:all) do
      @query = GScraper::Search::WebQuery.from_url("http://www.google.com/search?sa=N&start=0&q=#{Helpers::DEFAULT_QUERY}&num=20")
    end

    it "should have a results-per-page" do
      @query.results_per_page.should == 20
    end

    it "should have a query" do
      @query.query.should == Helpers::DEFAULT_QUERY
    end
  end

  it "should have atleast one similar query URL" do
    @page.similar_urls.length.should_not == 0
  end
end
