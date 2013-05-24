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

    get '/filter_branch_commits.json' do 
      include_commit_sha = params[:include]
      exclude_commit_sha = params[:exclude]

      branches = branches_include = branches_exclude = []
      branches_include = Visualisation.branches_containing_commit(include_commit_sha) if include_commit_sha != ''
      branches_exclude = Visualisation.branches_excluding_commit(exclude_commit_sha) if exclude_commit_sha != ''

      if !branches_include == {}
        branches = Hash[branches_include.to_a - branches_exclude.to_a]
      else
        branches = branches_exclude
      end

      content_type :json
      branches.to_json
    end

    get '/author_stats.json' do
      ref = params[:ref]

      authors = Visualisation.branch_author_stats(ref)
      content_type :json
      authors.to_json
    end

    get '/commits.json' do
      ref = params[:ref]
      commits = Visualisation.commits_for_branch(ref)

      content_type :json
      commits.to_json
    end

    get '/commit_diff_stats.json' do
      ref = params[:ref]
      file_diff_stats = Visualisation.merge_base_file_stats(ref)

      content_type :json
      file_diff_stats.to_json
    end
      
end

puts "Running GitVisualiser"
GitVisualiser.run!
