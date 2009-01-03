require 'leptonica-ffi'

module Leptonica

    FILE_FORMAT_MAPPING =
    {
        :unknown => 0,
        :bmp => 1,
        :jfif_jpeg => 2,
        :png => 3,
        :tiff => 4,
        :tiff_packbits => 5,
        :tiff_rle => 6,
        :tiff_g3 => 7,
        :tiff_g4 => 8,
        :tiff_lzw => 9,
        :tiff_zip => 10,
        :pnm => 11,
        :ps => 12,
        :gif => 13,
        :default => 14,
    }

    class Pix
        def self.read(pix)
            pointer = LeptonicaFFI.pixRead(pix)
            p pointer
            Leptonica::Pix.new(pointer)
        end

        attr_reader :pointer
        def initialize(pointer)
            @pointer = pointer
            ObjectSpace.define_finalizer(self, proc {|id| Pix.release(pointer)})
        end

        def self.release(pointer)
            pix_pointer = MemoryPointer.new :pointer
            pix_pointer.put_pointer(0, pointer)
            LeptonicaFFI.pixDestroy(pix_pointer)
        end

        def write(filename, format = :tiff)
            LeptonicaFFI.pixWrite(filename, @pointer, FILE_FORMAT_MAPPING[format])
        end

        def width
            LeptonicaFFI.pixGetWidth(@pointer)
        end

        def height
            LeptonicaFFI.pixGetHeight(@pointer)
        end

        def depth
            LeptonicaFFI.pixGetDepth(@pointer)
        end

        ###
        # Unary functions
        ###

        def invert
            Pix.new(LeptonicaFFI.pixInvert(nil, @pointer))
        end

        def invert!
            LeptonicaFFI.pixInvert(@pointer, @pointer)
        end

        ###
        # Binary Morphology
        ###

        def dilate(sel)
            Pix.new(LeptonicaFFI.pixDilate(nil, @pointer, sel.pointer))
        end

        def dilate!(sel)
            LeptonicaFFI.pixDilate(@pointer, @pointer, sel.pointer)
        end

        def erode(sel)
            Pix.new(LeptonicaFFI.pixErode(nil, @pointer, sel.pointer))
        end

        def erode!(sel)
            LeptonicaFFI.pixErode(@pointer, @pointer, sel.pointer)
        end

        def open(sel)
            Pix.new(LeptonicaFFI.pixOpen(nil, @pointer, sel.pointer))
        end

        def open!(sel)
            LeptonicaFFI.pixOpen(@pointer, @pointer, sel.pointer)
        end

        def close(sel)
            Pix.new(LeptonicaFFI.pixClose(nil, @pointer, sel.pointer))
        end

        def close!(sel)
            LeptonicaFFI.pixClose(@pointer, @pointer, sel.pointer)
        end

        ###
        # Grayscale Morphology
        ###

        def dilate_gray(width, height)
            Pix.new(LeptonicaFFI.pixDilateGray(@pointer, width, height))
        end

        def erode_gray(width, height)
            Pix.new(LeptonicaFFI.pixErodeGray(@pointer, width, height))
        end

        def open_gray(width, height)
            Pix.new(LeptonicaFFI.pixOpenGray(@pointer, width, height))
        end

        def close_gray(width, height)
            Pix.new(LeptonicaFFI.pixCloseGray(@pointer, width, height))
        end

        ###
        # Deskew
        ###

        def deskew
            Pix.new(LeptonicaFFI.pixDeskew(@pointer, 2))
        end

        ###
        # Convolution
        ###

        def block_conv(width, height)
            Pix.new(LeptonicaFFI.pixBlockconv(@pointer, width, height))
        end
    end

    class Sel
        attr_reader :pointer
        def initialize(pointer)
            @pointer = pointer
            ObjectSpace.define_finalizer(self, proc {|id| Sel.release(pointer)})
        end

        def self.create_brick(height, width, cy = 0, cx = 0, type = SEL_HIT)
            Sel.new(LeptonicaFFI.selCreateBrick(height, width, cy, cx, type))
        end

        def self.release(pointer)
            sel_pointer = MemoryPointer.new :pointer
            sel_pointer.put_pointer(0, pointer)
            LeptonicaFFI.selDestroy(sel_pointer)
        end
    end
end
