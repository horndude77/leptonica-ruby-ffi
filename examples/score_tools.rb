require 'leptonica'
require 'score_tools_ffi'

module ScoreTools
    def self.estimate_staff_parameters(pix)
        staff_height = MemoryPointer.new :uint32
        staff_space = MemoryPointer.new :uint32
        ScoreToolsFFI.estimate_staff_parameters(pix.pointer, staff_height, staff_space)
        [staff_height.get_uint(0), staff_space.get_uint(0)]
    end

    def self.adaptive_map_threshold(pix)
        reduction = 4
        map = pix.background_norm_gray_morph(reduction, 11, 128)
        norm = pix.apply_inv_background_gray_map(map, reduction)
        threshold = norm.estimate_global_threshold
        norm.threshold(threshold)
    end

    def self.deskew(pix)
        skew = 0.0
        if(pix.depth == 1)
            skew = pix.find_skew
        else
            threshold = pix.estimate_global_threshold
            skew = pix.threshold(threshold).find_skew
        end
        pix.rotate(degrees_to_radians(skew))
    end

    def self.split_in_half(pix)
        w = pix.width
        h = pix.height
        lbox = Leptonica::Box.create(0, 0, w/2, h)
        rbox = Leptonica::Box.create(w/2+1, 0, w/2, h)
        [pix.clip(lbox), pix.clip(rbox)]
    end

    def self.resize(pix, new_w, new_h)
        w = pix.width
        h = pix.height
        w_diff = new_w - w
        h_diff = new_h - h

        w_add = w_diff > 0 ? w_diff : 0
        h_add = h_diff > 0 ? h_diff : 0
        pix_expanded = if(w_add > 0 || h_add > 0)
                           pix.add_border(0, w_add, 0, h_add)
                       else
                           pix
                       end

        w_sub = w_diff < 0 ? w_diff.abs : 0
        h_sub = h_diff < 0 ? h_diff.abs : 0
        pix_reduced = if(w_sub > 0 || h_sub > 0)
                          pix_expanded.remove_border(0, w_sub, 0, h_sub)
                      else
                          pix_expanded
                      end
    end

    def self.files_to_pdf(files, filename)
        `tiffcp #{files.join(' ')} #{filename}.tiff`
        `tiff2pdf #{filename}.tiff -t"#{filename.gsub('_', ' ')}" -z -o #{filename}.pdf`
        `rm #{filename}.tiff`
    end

    def self.remove_edge_noise(image, smudge_factor = 51, max_iterations = 4)
        #remove some initial noise
        sel_b = Leptonica::Sel.create_brick(3, 3, 1, 1)

        #smudging bricks
        smudge_center = smudge_factor/2
        sel_h = Leptonica::Sel.create_brick(1, smudge_factor, 1, smudge_center)
        sel_v = Leptonica::Sel.create_brick(smudge_factor, 1, smudge_center, 1)

        count = 0
        content_mask = image.open(sel_b)
        loop do
            content_mask.dilate!(sel_h)
            content_mask.dilate!(sel_v)
            count += 1
            #p content_mask.count_connected_components
            break if(content_mask.count_connected_components <= 1 || count >= max_iterations)
            #BUG: Sometimes the far right column doesn't get set by a
            #horizontal dilate. Setting the border pixels as a workaround.
            content_mask.set_border!(1, 1, 1, 1)
            content_mask = content_mask.remove_border_components
            #content_mask.write("mask#{count}.tiff", :tiff_g4)
        end
        image.and(content_mask)
    end

    def self.center!(image)
        #Do an opening to hopefully avoid some noise. This might remove some
        #content. If it does open with a smaller brick.
        sel = Leptonica::Sel.create_brick(7, 7, 3, 3)
        boxa = image.open(sel).connected_components
        bounding_box = boxa.extent
        x = bounding_box.x
        y = bounding_box.y
        w = bounding_box.w
        h = bounding_box.h
        sx = (image.width - w - 2*x)/2
        sy = (image.height - h - 2*y)/2
        image.shift!(sx, sy)
    end

    def self.degrees_to_radians(angle)
        angle*(Math::PI/180.0)
    end

    def self.radians_to_degrees(angle)
        angle*(180.0/Math::PI)
    end
end
