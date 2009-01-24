require 'leptonica-ffi'

module Leptonica
    class Box < PointerClass
        def self.create(x, y, width, height)
            Box.new(LeptonicaFFI.boxCreate(x, y, width, height))
        end

        def self.release(pointer)
            box_pointer = MemoryPointer.new :pointer
            box_pointer.put_pointer(0, pointer)
            LeptonicaFFI.boxDestroy(box_pointer)
        end

        def initialize(pointer)
            super(pointer)
        end

        def x
            int_pointer = MemoryPointer.new :int32
            LeptonicaFFI.boxGetGeometry(pointer, int_pointer, nil, nil, nil)
            int_pointer.get_int32(0)
        end

        def y
            int_pointer = MemoryPointer.new :int32
            LeptonicaFFI.boxGetGeometry(pointer, nil, int_pointer, nil, nil)
            int_pointer.get_int32(0)
        end

        def w
            int_pointer = MemoryPointer.new :int32
            LeptonicaFFI.boxGetGeometry(pointer, nil, nil, int_pointer, nil)
            int_pointer.get_int32(0)
        end

        def h
            int_pointer = MemoryPointer.new :int32
            LeptonicaFFI.boxGetGeometry(pointer, nil, nil, nil, int_pointer)
            int_pointer.get_int32(0)
        end
    end

    class BoxA < PointerClass
        def initialize(pointer)
            super(pointer)
        end

        def self.release(pointer)
            boxa_pointer = MemoryPointer.new :pointer
            boxa_pointer.put_pointer(0, pointer)
            LeptonicaFFI.boxaDestroy(boxa_pointer)
        end

        def extent
            box_pointer = MemoryPointer.new :pointer
            boxa = LeptonicaFFI.boxaGetExtent(pointer, nil, nil, box_pointer)
            bounding_box = Leptonica::Box.new(box_pointer.get_pointer(0))
        end

        def each
            count.times do |i|
                yield self[i]
            end
        end

        def count
            LeptonicaFFI.boxaGetCount(pointer)
        end

        def [](index)
            Box.new(LeptonicaFFI.boxaGetBox(pointer, index, L_COPY))
        end
    end
end
