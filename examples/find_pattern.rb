#!/usr/bin/env ruby

SCRIPT_DIR = File.dirname($0)
$LOAD_PATH << "#{SCRIPT_DIR}/../lib"

require 'rubygems'
require 'leptonica'

image = Leptonica::Pix.read(ARGV[0])
pattern = Leptonica::Pix.read(ARGV[1])
pw = pattern.width
ph = pattern.height

num_h_lines = 20
num_v_lines = 20
distance = 0
minlength = 0
border = 5
sel, expanded = Leptonica::Sel.generate_sel_with_runs2(pattern, num_h_lines, num_v_lines, distance, minlength, border, border, border, border)
sel_display = sel.hit_miss_sel_to_pix(expanded)
sel_display.write('hmt_sel.tiff')

out = image.hmt(sel)
#out.dilate!(sel)

boxes = out.connected_components
boxes.each do |box|
    boxe = Leptonica::Box.create(box.x-pw/2, box.y-ph/2, pw+4, ph+4)
    image.render_box!(boxe)

    #To erase instead:
    #image.clear_box!(boxe)
end

image.write('out.tiff', :tiff_g4)
