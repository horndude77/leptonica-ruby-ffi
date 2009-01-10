spec = Gem::Specification.new do |s|
    s.name = 'leptonica'
    s.version = '0.0.1'
    s.author = 'Jay Anderson'
    s.email = 'horndude77@gmail.com'
    s.platform = Gem::Platform::RUBY
    s.summary = 'FFI interface to leptonica library'
    s.files = Dir.glob('lib/*.rb')
    s.require_path = 'lib'
    s.autorequire = 'leptonica'
    s.has_rdoc = false
    #s.add_dependency("ffi", ">= 0.2.0")
end
