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

    SEL_TYPE_MAPPING =
    {
        :dont_care => 0,
        :hit => 1,
        :miss => 2,
    }

    class Pix
        def self.read(pix)
            pointer = LeptonicaFFI.pixRead(pix)
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
        # Pixel accessors
        ###

        def [](row, col)
            pixel_pointer = MemoryPointer.new :int32
            LeptonicaFFI.pixGetPixel(@pointer, col, row, pixel_pointer)
            pixel_pointer.get_int(0)
        end

        def []=(row, col, val)
            LeptonicaFFI.pixSetPixel(@pointer, col, row, val)
            self
        end

        ###
        # Binary Morphology
        ###

        def dilate(sel)
            Pix.new(LeptonicaFFI.pixDilate(nil, @pointer, sel.pointer))
        end

        def dilate!(sel)
            LeptonicaFFI.pixDilate(@pointer, @pointer, sel.pointer)
            self
        end

        def erode(sel)
            Pix.new(LeptonicaFFI.pixErode(nil, @pointer, sel.pointer))
        end

        def erode!(sel)
            LeptonicaFFI.pixErode(@pointer, @pointer, sel.pointer)
            self
        end

        def open(sel)
            Pix.new(LeptonicaFFI.pixOpen(nil, @pointer, sel.pointer))
        end

        def open!(sel)
            LeptonicaFFI.pixOpen(@pointer, @pointer, sel.pointer)
            self
        end

        def close(sel)
            Pix.new(LeptonicaFFI.pixClose(nil, @pointer, sel.pointer))
        end

        def close!(sel)
            LeptonicaFFI.pixClose(@pointer, @pointer, sel.pointer)
            self
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
        # Binary Operations
        ###

        def invert
            Pix.new(LeptonicaFFI.pixInvert(nil, @pointer))
        end

        def invert!
            LeptonicaFFI.pixInvert(@pointer, @pointer)
            self
        end
        
        def and(other)
            Pix.new(LeptonicaFFI.pixAnd(nil, @pointer, other.pointer))
        end
        
        def and!(other)
            LeptonicaFFI.pixAnd(@pointer, @pointer, other.pointer)
            self
        end
        
        def or(other)
            Pix.new(LeptonicaFFI.pixOr(nil, @pointer, other.pointer))
        end
        
        def or!(other)
            LeptonicaFFI.pixOr(@pointer, @pointer, other.pointer)
            self
        end
        
        def xor(other)
            Pix.new(LeptonicaFFI.pixXor(nil, @pointer, other.pointer))
        end
        
        def xor!(other)
            LeptonicaFFI.pixXor(@pointer, @pointer, other.pointer)
            self
        end
        
        def subtract(other)
            Pix.new(LeptonicaFFI.pixSubtract(nil, @pointer, other.pointer))
        end
        
        def subtract!(other)
            LeptonicaFFI.pixSubtract(@pointer, @pointer, other.pointer)
            self
        end

        ###
        # Threshold
        ###

        def threshold(threshold)
            Pix.new(LeptonicaFFI.pixConvertTo1(@pointer, threshold))
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

        ###
        # Clipping
        ###

        def clip(box)
            Pix.new(LeptonicaFFI.pixClipRectangle(@pointer, box.pointer, nil))
        end
    end

    class Sel
        attr_reader :pointer
        def initialize(pointer)
            @pointer = pointer
            ObjectSpace.define_finalizer(self, proc {|id| Sel.release(pointer)})
        end

        def self.create_empty(height, width, name = nil)
            Sel.new(LeptonicaFFI.selCreate(height, width, name))
        end

        def self.create_brick(height, width, cy = 0, cx = 0, type = :hit)
            Sel.new(LeptonicaFFI.selCreateBrick(height, width, cy, cx, SEL_TYPE_MAPPING[type]))
        end

        def self.release(pointer)
            sel_pointer = MemoryPointer.new :pointer
            sel_pointer.put_pointer(0, pointer)
            LeptonicaFFI.selDestroy(sel_pointer)
        end

        def rotate_orth(n)
            Sel.new(LeptonicaFFI.selRotateOrth(@pointer, n))
        end

        def []=(row, col, val)
            LeptonicaFFI.selSetElement(@pointer, row, col, SEL_TYPE_MAPPING[val])
        end
    end

    class Box
        attr_reader :pointer
        def initialize(pointer)
            @pointer = pointer
            ObjectSpace.define_finalizer(self, proc {|id| Box.release(pointer)})
        end

        def self.create(x, y, width, height)
            Box.new(LeptonicaFFI.boxCreate(x, y, width, height))
        end

        def self.release(pointer)
            box_pointer = MemoryPointer.new :pointer
            box_pointer.put_pointer(0, pointer)
            LeptonicaFFI.boxDestroy(box_pointer)
        end
    end
end
