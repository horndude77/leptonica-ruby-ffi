require 'rubygems'
Gem::manage_gems
require 'rake/gempackagetask'

spec = eval(File.read('leptonica.gemspec'))

Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_tar = true
end

task :default => "pkg/#{spec.name}-#{spec.version}.gem" do
    puts "generated gem"
end
