class CoffeeEngine < Sinatra::Base
  
  set :views,   File.dirname(__FILE__)    + '/public/javascripts'

  get "/javascripts/d3.min.js" do
  end

  get "/javascripts/jquery.min.js" do
  end

  get "/javascripts/moment.min.js" do
  end
  
  get "/javascripts/*.js" do
    filename = params[:splat].first
    coffee filename.to_sym
  end
  
end