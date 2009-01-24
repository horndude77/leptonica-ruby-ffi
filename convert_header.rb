#!/usr/bin/env ruby

#
#This simple file is used to convert leptprotos.h (and possibly other header
#files) into a list of function signatures that ruby ffi can understand.
#

class Signature < Struct.new(:name, :return_type, :arguments)
    def to_s
        "[:#{name}, [#{arguments.map{|a|a.inspect}.join(', ')}], #{return_type.inspect}]"
    end
end

TYPE_MAPPING = {
    'l_uint8' => :uint8,
    'l_uint16' => :uint16,
    'l_int32' => :int32,
    'l_uint32' => :uint32,
    'l_float32' => :float,
    'void' => :void,
    'char' => :char,
    'size_t' => :uint64,
}

def get_type(s)
    if(s =~ /\*/)
        :pointer
    else
        TYPE_MAPPING[s.split(' ').first]
    end
end

signatures = []
header_file = ARGV[0]
File.open(header_file, 'r') do |f|
    f.each do |line|
        if(line =~ /\w\w*\s*(.*);\s*$/)
            line['extern'] = ''
            line['const'] = ''
            first, mid, last = line.split(/[\(\)]/)
            name = first.split(' ').last
            return_type = get_type(first)
            arguments = mid.split(',').map{|s|get_type(s)}
            signatures << Signature.new(name, return_type, arguments)
        end
    end
end

puts "    [\n        "
puts signatures.join(",\n        ")
puts "    ]"
