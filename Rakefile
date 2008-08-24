
require 'spec/rake/spectask'

desc "Run all specs"
Spec::Rake::SpecTask.new('spec') do |t|
  t.libs << File.dirname(__FILE__) + '/lib'
  t.spec_files = FileList[File.dirname(__FILE__) + '/spec/**/*_spec.rb']
end
