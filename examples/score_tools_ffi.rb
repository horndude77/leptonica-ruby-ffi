require 'rubygems'
require 'ffi'

module ScoreToolsFFI
    extend FFI::Library
    SCORE_TOOLS_DIR = File.dirname(__FILE__)
    ffi_lib "#{SCORE_TOOLS_DIR}/libscore_tools.so"

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
