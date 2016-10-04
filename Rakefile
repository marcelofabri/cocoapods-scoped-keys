require 'bundler/gem_tasks'

def specs(dir)
  FileList["spec/#{dir}/*_spec.rb"].shuffle.join(' ')
end

desc 'Run tests'
task :spec do
  sh "bundle exec rspec #{specs('**')}"
  sh 'bundle exec rubocop lib spec Rakefile'
end

task default: :spec
