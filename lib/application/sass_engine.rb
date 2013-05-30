class SassEngine < Sinatra::Base
  
  set :views,   File.dirname(__FILE__)    + '/public/stylesheets/scss'

   get '/stylesheets/flat_ui.css' do
    sass 'flat_ui/flat-ui'.to_sym
  end
  
  get '/stylesheets/*.css' do
    filename = params[:splat].first
    scss filename.to_sym
  end
  
end