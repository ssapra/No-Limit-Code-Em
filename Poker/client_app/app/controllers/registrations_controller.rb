class RegistrationsController < ApplicationController
  def new
    @request = Request.new
  end
  
  def post
    
    require 'net/http'
    begin
    # hostname = params[:request][:hostname]
    #     port = params[:request][:port_number]
    #     name = params[:request][:name]
    #     Request.create(params[:request])
    
    #url = URI.parse("http://#{hostname}:#{port}")

    #body = {:name => name, :hostname => "localhost", :port_number => 3001}
  
    #response = Net::HTTP.post_form(url, body)
    
    if response.code.to_i == 302
        redirect_to confirmation_path
    end
    
    
    rescue
      @warning = "Server not found"
    end
    

    #@host = 'localhost'
    #@port = '3000'

    #@path = "/posts"

    # request = Net::HTTP::Post.new(@path, initheader = {'Content-Type' =>'application/json'})
    #  request.body = @body
    #  response = Net::HTTP.new(@host, @port).start {|http| http.request(request) }
    #  puts "Response #{response.code} #{response.message}: #{response.body}"
  end
  
  def confirmation
    @params = Request.last
    
  end
  
  
end
