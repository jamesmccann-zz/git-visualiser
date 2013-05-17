require 'sinatra/base'
require 'haml' # if you use haml views
require 'coffee-script'
require 'sass'
require 'json'

class GitVisualiser < Sinatra::Base

    use SassEngine
    use CoffeeEngine

    set :static, true                             
    set :public_dir, File.expand_path('..', __FILE__) 
        
    set :views,  File.expand_path('../views', __FILE__) 
    set :haml, { :format => :html5 }                    
            
    get '/' do
      haml :'/index'
    end

    get '/branches.json' do
      branches = Visualisation.branches
      content_type :json
      branches.to_json
    end

    get '/merged_branches.json' do
      merged_branches = Visualisation.repo_branches_merged
      content_type :json
      merged_branches.to_json
    end
            
end
