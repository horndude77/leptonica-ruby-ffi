require 'rubygems'
require 'ffi'

module ScoreToolsFFI
    extend FFI::Library
    SCRIPT_DIR = File.dirname($0)
    ffi_lib "#{SCRIPT_DIR}/libscore_tools.so"

    functions =
    [
        [:estimate_staff_parameters, [:pointer, :pointer, :pointer], :void],
    ]

    @unattached_functions = []
    class << self
        def unattached_functions
            @unattached_functions
        end
    end

    functions.each do |func|
        begin
            attach_function(*func)
        rescue Object => e
            p e
            unattached_functions << func[0]
        end
    end
end
