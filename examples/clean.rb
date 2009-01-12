#!/usr/bin/env ruby

#This script is used to convert a bunch of grayscale image to black&white and
#then compile the in a pdf.

SCRIPT_DIR = File.dirname($0)
$LOAD_PATH << SCRIPT_DIR
$LOAD_PATH << "#{SCRIPT_DIR}/../lib"

require 'rubygems'
require 'leptonica'
require 'score_tools'

#Convert a grayscale image to a b&w image of size w x h.
def clean_image(image, w, h)
    image = ScoreTools.deskew(image)
    image = ScoreTools.adaptive_map_threshold(image)
    image = ScoreTools.resize(image, w, h)
    image = ScoreTools.remove_edge_noise(image)
    image = ScoreTools.center!(image)
    image
end

out_file_prefix = "out"
page = '0000'
double_page = false
name = 'out'
width, height = 0, 0

i = 0
while(ARGV[i] =~ /^-/)
    if(ARGV[i] == '-double-page')
        double_page = true
        i += 1
    elsif(ARGV[i] == '-name')
        i += 1
        name = ARGV[i]
        i += 1
    elsif(ARGV[i] == '-size')
        i += 1
        width, height = ARGV[i].split('x').map{|x|x.to_i}
        i += 1
    end
end

if(width == 0 || height==0)
    puts "Invalid size"
    exit
end

files = ARGV[i..-1]
files.each do |file|
    puts page
    image = Leptonica::Pix.read(file)

    if(double_page)
        left, right = ScoreTools.split_in_half(image)

        left = clean_image(left, width, height)
        left.write("#{out_file_prefix}#{page}.tiff", :tiff_g4)
        page.succ!

        right = clean_image(right, width, height)
        right.write("#{out_file_prefix}#{page}.tiff", :tiff_g4)
        page.succ!
    else
        image = clean_image(image, width, height)
        image.write("#{out_file_prefix}#{page}.tiff", :tiff_g4)
        page.succ!
    end

    #Free the image (hopefully)
    GC.start
end

ScoreTools.files_to_pdf(Dir["out*.tiff"].sort, name)

