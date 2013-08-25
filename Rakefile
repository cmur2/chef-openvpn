
# use rspec
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |task|
  # exclude spec files from other cookbooks
  task.pattern = FileList['spec/**/*_spec.rb'].exclude('spec/support/**/*_spec.rb')
end

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
