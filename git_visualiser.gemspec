Gem::Specification.new do |s|
  s.name        = 'git-visualiser'
  s.version     = '0.0.1'
  s.date        = '2013-05-18'
  s.summary     = "Sinatra app for Git Visualisation"
  s.description = "A Sinatra app for loading D3-based visualisations of a local Git repository"
  s.authors     = ["James McCann"]
  s.email       = 'jmccnz@gmail.com'
  s.files       = Dir.glob("{bin,lib}/**/*") + %w(config.ru)
  s.homepage    = 'http://rubygems.org/gems/git-visualiser'
  s.executables = ['git_vis']
  s.default_executable = 'git_vis'
end