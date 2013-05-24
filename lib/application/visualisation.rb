module Visualisation
  require 'csv'
  require 'date'

  def self.branches
    branches_arr = [] 
    total_additions = total_deletions = 0
    remotes_arr = Visualisation.remotes
    Visualisation.branches_with_remotes.each do |branch|
      diff = Visualisation.branch_diff_size(branch)
      head_commit = Visualisation.head_commit_sha(branch)
      merged_with_master = Visualisation.branch_contains_commit("master", head_commit)
      total_additions += diff.first
      total_deletions += diff.last
      remote = remotes_arr.include?(branch)
      branches_arr << {:name => branch, :diff => {:add => diff.first, :del => diff.last}, 
                    :merged_with_master => merged_with_master, :hidden => false, :remote => remote}
    end
    result = {:branches => branches_arr, :diff => {:add => total_additions, :del => total_deletions}}
    result
  end

  def self.branches_with_remotes
    `git branch -a`.split("\n").each { |b| b.gsub!(/[*]?\s/, '') and b.gsub!(/remotes\//, '') }
      .delete_if { |b| b.include?('->') }
  end

  def self.remotes
    `git branch -r`.split("\n").each { |b| b.gsub!(/[*]?\s/, '') }
  end

  def self.head_commit_sha(branch)
    `git rev-parse #{branch}`
  end

  def self.branch_contains_commit(branch, commit_sha)
    `git branch --contains #{commit_sha}`.split("\n").each {|b| b.gsub!(/[*]?\s/, '')}.include?(branch)
  end

  def self.branches_containing_commit(commit_sha, remotes = true)
    if remotes 
      return `git branch -a --contains #{commit_sha}`.split("\n").each { |b| b.gsub!(/[*]?\s/, '') and b.gsub!(/remotes\//, '') }
    else 
      return `git branch --contains #{commit_sha}`.split("\n").each { |b| b.gsub!(/[*]?\s/, '') }
    end
  end

  def self.branches_excluding_commit(commit_sha, remotes = true)
    if remotes
      return branches_with_remotes - `git branch --contains #{commit_sha}`.split("\n").each { |b| b.gsub!(/[*]?\s/, '') }
    else
      # TODO fix this
      # return branches - `git branch --contains #{commit_sha}`.split("\n").each { |b| b.gsub!(/[*]?\s/, '') }
    end
  end

  def self.branch_diff_number_commits(branch)
    `git cherry master #{branch}`.split("\n").size
  end 

  def self.repo_branches_merged(show_remotes = true)
    merged_branches = {}
    compare_branches = branches_with_remotes
    compare_branches.each do |b1|
      b1_merges = {}
      compare_branches.each do |b2|
        next if b1 == b2 || b2.split("/").last == b1 || 
            (merged_branches.has_key?(b2.to_sym) && merged_branches[b2.to_sym].has_key?(b1.to_sym))
        directions = {}
        directions.merge!(:left => true) if branch_merged_with_base?(b1, b2, remotes)
        directions.merge!(:right => true) if right = branch_merged_with_base?(b2, b1, remotes)
        b1_merges.merge!(b2.to_sym => directions)
      end
      merged_branches.merge!(b1.to_sym => b1_merges)
    end
    merged_branches
  end

  def self.branch_merged_with_base?(base, branch, remotes)
    if remotes 
      `git branch -a --merged #{base} #{branch}`.length > 0
    else
      `git branch --merged #{base} #{branch}`.length > 0
    end
  end
  
  #printout merge commits between base and topic branch
  #`git log #{branch} #{base} --oneline --date-order --merges --reverse -1`

  def self.branch_diff_size(branch)
    merge_base_commit = `git merge-base master #{branch}`.gsub("/\n/", '').strip!
    raw_diff_stats = `git diff --numstat #{merge_base_commit} #{branch}`
    diff_stats = raw_diff_stats.split(/\n/)
    additions = deletions = 0
    diff_stats.each do |line|
      cols = line.split
      additions += cols[0].to_i 
      deletions += cols[1].to_i 
    end

    return additions, deletions
  end

  def self.commits_for_branch(branch_name)
    commits = []
    raw_log = `git log  master..#{branch_name} --max-count 15 --date=short --pretty="%H, %an, %ad, %s"`
    commit_lines = CSV.parse(raw_log)
    i = 1
    last_date = nil
    commit_lines.each_with_index do |commit, id|
      sha1 = commit[0]
      author = commit[1].strip!
      commit_date = Date.parse(commit[2].strip!)
      message = commit.slice(3..commit.length-1).join(",").strip!
      if !last_date.nil? && 
        (commit_date.year == last_date.year && commit_date.yday == last_date.yday)
        i += 1
      else
        i = 1
      end
      last_date = commit_date.to_date
      commit_stats = {:id => id, :date => last_date, :num => i, :sha => sha1, 
                      :author => author, :message => message}
      commits << commit_stats
      puts commits
    end
    commits
  end

  def self.merge_base_file_stats(branch_name)
    `git log master..#{branch_name} --numstat --no-merges --format="%n"`
  end

  def self.commit_diff_stats(commit_sha)
    `git show #{commit_sha} --numstat --no-merges --pretty="%n"`.strip!
  end


  def self.branch_diff_commit_files(commit_sha = nil)
    merge_base_commit = `git merge-base master #{commit_sha}`.gsub("/\n/", '').strip!
    diff_stats = `git diff --numstat #{merge_base_commit} #{commit_sha}`.split(/\n/)
    files = {}
    additions = deletions = 0
    diff_stats.each do |line|
      cols = line.split
      additions += cols[0].to_i 
      deletions += cols[1].to_i 
      files.merge!(cols[2].to_sym => { :add => additions, :del => deletions })
    end
    files.merge!(:total => { :add => additions, :del => deletions })
  end

  def self.branch_author_stats(branch)
    authors = []
    raw_authors = `git log master..#{branch} --pretty=format:%an,%ae \
      | awk '{ ++c[$0]; } END { for(cc in c) printf "%5d,%s\\n",c[cc],cc; }'\
      | sort -r`.split(/\n/).each { |c| c.strip! }.slice(0, 3)
    raw_authors.each do |author|
      author = author.split(/,/)
      authors << {:name => author[1], :commits => author[0], :gravatar_url => gravatar_url(author[2])} 
    end
    authors
  end

  def self.gravatar_url(email) 
    hash = Digest::MD5.hexdigest(email).to_s
    "http://www.gravatar.com/avatar/#{hash}?s=40"
  end

end