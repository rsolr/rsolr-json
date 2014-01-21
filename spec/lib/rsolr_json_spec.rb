require 'spec_helper'

describe RSolr::Json do
  let(:mock_connection) { double() }
  let(:client) { RSolr::Client.new mock_connection}

  it "should use wt => json" do
    opts = client.build_request "select", {}
    expect(opts[:params][:wt]).to eq :json
  end

  it "should use a provided wt" do
    opts = client.build_request "select", :params => { :wt => 'custom-wt' }
    expect(opts[:params][:wt]).to eq 'custom-wt'
  end

  it "should parse json responses" do
    mock_request = { :params => { :wt => :json }}
    mock_response = { :body => '{ }', :headers => nil, :status => 200}
    response = client.adapt_response mock_request, mock_response
    expect(response).to be_a_kind_of Hash
    expect(response).to be_a_kind_of RSolr::Client::Context
    expect(response.request).to eq mock_request
    expect(response.response).to eq mock_response
  end

  it "should ignore non-json responses" do
    mock_request = { :params => { :wt => :xyz }}
    mock_response = { :body => 'asdf', :headers => nil, :status => 200}
    response = client.adapt_response mock_request, mock_response
    expect(response).to eq 'asdf'
  end
end