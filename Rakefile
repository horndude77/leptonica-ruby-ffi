require 'rubygems'
require 'rubygems/package_task'

spec = eval(File.read('leptonica-ruby-ffi.gemspec'))

Gem::PackageTask.new(spec) do |pkg|
    pkg.need_tar = true
end

task :default => "pkg/#{spec.name}-#{spec.version}.gem" do
    puts "generated gem"
end
