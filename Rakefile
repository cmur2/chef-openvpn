
# use rspec
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

# try to use foodcritic
begin
  require 'foodcritic'

  FoodCritic::Rake::LintTask.new do |task|
    task.options = { :fail_tags => [ 'any' ], :tags => [ '~FC007' ] }
  end

  task :default => [ :foodcritic, :spec ]
rescue LoadError
  task :default => [ :spec ]
end
