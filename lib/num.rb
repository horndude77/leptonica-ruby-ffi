require 'leptonica-ffi'

module Leptonica
    class NumA < PointerClass
        def initialize(pointer)
            super(pointer)
        end

        def self.release(pointer)
            numa_pointer = MemoryPointer.new :pointer
            numa_pointer.put_pointer(0, pointer)
            LeptonicaFFI.numaDestroy(numa_pointer)
        end

        def self.create(size)
            NumA.new(LeptonicaFFI.numaCreate(size))
        end

        def self.create_from_int_array(pointer, size)
            NumA.new(LeptonicaFFI.numaCreateFromIArray(pointer, size))
        end

        def find_peaks(max_peaks = 1000, min_frac = 0.5, min_slope = 1.0)
            NumA.new(LeptonicaFFI.numaFindPeaks(pointer, max_peaks, min_frac, min_slope))
        end

        def each
            count.times do |i|
                yield self[i]
            end
        end

        def get_float(index)
            f_pointer = MemoryPointer.new :float
            LeptonicaFFI.numaGetFValue(pointer, index, f_pointer)
            f_pointer.get_float32(0)
        end

        def count
            LeptonicaFFI.numaGetCount(pointer)
        end

        def [](index)
            self.get_float(index)
        end
    end
end
