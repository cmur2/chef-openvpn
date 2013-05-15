
guard 'rspec', :all_after_pass => false, :all_on_start => false do
  # general pathes for cookbooks
  watch(%r{^attributes/(.+)\.rb$}) { "spec" }
  watch(%r{^files/(.+)\.rb$}) { "spec" }
  watch(%r{^libraries/(.+)\.rb$}) { "spec" }
  watch(%r{^templates/(.+)\.rb$}) { "spec" }
  
  # directly related to a specific recipe
  watch(%r{^recipes/(.+)\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^spec/(.+)_spec\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
  
  # general pathes for rspec
  watch(%r{^spec/support/(.+)\.rb$}) { "spec" }
  watch('spec/spec_helper.rb') { "spec" }
end

# load Guardfile.local
local_guardfile = File.dirname(__FILE__) + "/Guardfile.local"
if File.file?(local_guardfile)
  self.instance_eval(Bundler.read_file(local_guardfile))
end
