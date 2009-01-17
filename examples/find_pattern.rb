#!/usr/bin/env ruby

SCRIPT_DIR = File.dirname($0)
$LOAD_PATH << "#{SCRIPT_DIR}/../lib"

require 'rubygems'
require 'leptonica'

def remove_pattern!(image, patterns)
    patterns.each do |pattern|
        pw = pattern.width
        ph = pattern.height

        num_h_lines = 10
        num_v_lines = 10
        distance = 0
        minlength = 0
        border = 5
        sel, expanded = Leptonica::Sel.generate_sel_with_runs2(pattern, num_h_lines, num_v_lines, distance, minlength, border, border, border, border)
        sel_display = sel.hit_miss_sel_to_pix(expanded)
        sel_display.write('hmt_sel.tiff')

        out = image.hmt(sel)
        #out.dilate!(sel)

        draw_box = false
        if draw_box
            boxes = out.connected_components
            boxes.each do |box|
                boxe = Leptonica::Box.create(box.x-pw/2, box.y-ph/2, pw+4, ph+4)
                image.render_box!(boxe)

                #To erase box instead:
                #image.clear_box!(boxe)
            end
        else
            image.remove_matched_pattern!(pattern, out, sel.cx, sel.cy, 3)
        end
    end
    image
end

def remove_red_parts(image)
    r = image.get_rgb_component(Leptonica::COLOR_RED)
    g = image.get_rgb_component(Leptonica::COLOR_GREEN)
    #b = image.get_rgb_component(Leptonica::COLOR_BLUE)
    mask = r.subtract!(g).invert!.threshold(128)

    out = image.threshold(128)
    mask.connected_components.each do |box|
        out.clear_box!(box)
    end
    out
end

if(ARGV.size < 3)
    puts "Usage #{File.basename($0)} [input image] [output filename] [pattern1] [pattern2] ..."
    exit
end

in_filename, out_filename, *patterns = ARGV

image = Leptonica::Pix.read(in_filename)
patterns = patterns.map{|pattern_filename| Leptonica::Pix.read(pattern_filename)}

if(image.depth > 8)
    image = remove_red_parts(image)
elsif(image.depth > 1)
    threshold = 5
    image = image.threshold(threshold)
    image.write('asdf-1.tiff', :tiff_g4)
else
    remove_pattern!(image, patterns)
end

image.write(out_filename, :tiff_g4)
