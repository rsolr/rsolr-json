require "rsolr/json/version"
require 'rsolr'
require 'rsolr/client'
require 'multi_json'

module RSolr
  module Json
    # Your code goes here...
  end

  class Client

    alias_method :orig_build_request, :build_request
    alias_method :orig_adapt_response, :adapt_response

    def build_request path, opts
      opts[:params] = opts[:params].nil? ? {:wt => :json} : {:wt => :json}.merge(opts[:params])
      orig_build_request path, opts
    end

    def adapt_response request, response
      raise "The response does not have the correct keys => :body, :headers, :status" unless
      %W(body headers status) == response.keys.map{|k|k.to_s}.sort
      raise RSolr::Error::Http.new request, response unless [200,302].include? response[:status]
      case request[:params][:wt]
        when :ruby
          orig_adapt_response request, response
        when :json
          result = evaluate_json_response(request, response)
          result.extend Context
          result.request, result.response = request, response
          result.is_a?(Hash) ? result.extend(RSolr::Response) : result
        else
          orig_adapt_response request, response
      end
    end

    def evaluate_json_response request, response
      begin
        MultiJson.load response[:body].to_s
      rescue MultiJson::LoadError
        raise RSolr::Error::InvalidRubyResponse.new request, response
      end
    end 
  end
end
