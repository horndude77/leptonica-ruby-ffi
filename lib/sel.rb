require 'leptonica-ffi'

module Leptonica

    SEL_DONT_CARE = 0
    SEL_HIT = 1
    SEL_MISS = 2

    class Sel < PointerClass
        def self.create_empty(height, width, name = nil)
            Sel.new(LeptonicaFFI.selCreate(height, width, name))
        end

        def self.create_brick(height, width, cy = 0, cx = 0, type = SEL_HIT)
            Sel.new(LeptonicaFFI.selCreateBrick(height, width, cy, cx, type))
        end

        def self.generate_sel_with_runs(pix, nhlines, nvlines, distance, minlength, toppix, botpix, leftpix, rightpix)
            Sel.new(
                LeptonicaFFI.pixGenerateSelWithRuns(
                    pix.pointer,
                    nhlines,
                    nvlines,
                    distance,
                    minlength,
                    toppix,
                    botpix,
                    leftpix,
                    rightpix,
                    nil))
        end

        def self.generate_sel_with_runs2(pix, nhlines, nvlines, distance, minlength, toppix, botpix, leftpix, rightpix)
            expanded_pix_pointer = MemoryPointer.new :pointer
            sel = Sel.new(
                LeptonicaFFI.pixGenerateSelWithRuns(
                    pix.pointer,
                    nhlines,
                    nvlines,
                    distance,
                    minlength,
                    toppix,
                    botpix,
                    leftpix,
                    rightpix,
                    expanded_pix_pointer))
            [sel, Pix.new(expanded_pix_pointer.get_pointer(0))]
        end

        def self.release(pointer)
            sel_pointer = MemoryPointer.new :pointer
            sel_pointer.put_pointer(0, pointer)
            LeptonicaFFI.selDestroy(sel_pointer)
        end

        def initialize(pointer)
            super(pointer)
        end

        def set_origin(y, x)
            LeptonicaFFI.selSetOrigin(pointer, y, x)
        end

        def height
            int_pointer = MemoryPointer.new :int32
            LeptonicaFFI.selGetParameters(pointer, int_pointer, nil, nil, nil)
            int_pointer.get_int32(0)
        end

        def width
            int_pointer = MemoryPointer.new :int32
            LeptonicaFFI.selGetParameters(pointer, nil, int_pointer, nil, nil)
            int_pointer.get_int32(0)
        end

        def cy
            int_pointer = MemoryPointer.new :int32
            LeptonicaFFI.selGetParameters(pointer, nil, nil, int_pointer, nil)
            int_pointer.get_int32(0)
        end

        def cx
            int_pointer = MemoryPointer.new :int32
            LeptonicaFFI.selGetParameters(pointer, nil, nil, nil, int_pointer)
            int_pointer.get_int32(0)
        end

        def rotate_orth(n)
            Sel.new(LeptonicaFFI.selRotateOrth(pointer, n))
        end

        def hit_miss_sel_to_pix(pix, hit_color = 0xff880000, miss_color = 0x00ff8800, scale = 0)
            Pix.new(LeptonicaFFI.pixDisplayHitMissSel(pix.pointer, pointer, scale, hit_color, miss_color))
        end

        def []=(row, col, val)
            LeptonicaFFI.selSetElement(pointer, row, col, val)
        end
    end
end
