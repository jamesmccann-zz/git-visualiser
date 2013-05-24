Gem::Specification.new do |s|
  s.name        = 'git-visualiser'
  s.version     = '0.0.7'
  s.date        = '2013-05-18'
  s.summary     = "Sinatra app for Git Visualisation"
  s.description = "A Sinatra app for loading D3-based visualisations of a local Git repository"
  s.authors     = ["James McCann"]
  s.email       = 'jmccnz@gmail.com'
  s.files       = Dir.glob("{bin,lib}/**/*")
  s.homepage    = 'http://rubygems.org/gems/git-visualiser'
  s.executables = ['git_vis']
  s.default_executable = 'git_vis'

  s.add_dependency('sinatra')
  s.add_dependency('thin')
  s.add_dependency('coffee-script')
  s.add_dependency('haml')
  s.add_dependency('sass')
  s.add_dependency('json', '~> 1.7.7')
end
