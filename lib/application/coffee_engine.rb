class CoffeeEngine < Sinatra::Base
  
  set :views,   File.dirname(__FILE__)    + '/javascripts'
  set :public_dir, File.expand_path('..', __FILE__)

  get "/javascripts/d3.min.js" do
  end

  get "/javascripts/jquery.min.js" do
  end
  
  get "/javascripts/*.js" do
    filename = params[:splat].first
    coffee filename.to_sym
  end
  
end