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
    image = image.unsharp_mask(6, 0.7)
    image = image.scale_2x
    image = ScoreTools.deskew(image)
    image = ScoreTools.adaptive_map_threshold(image)
    image = ScoreTools.remove_edge_noise(image)
    image = ScoreTools.resize(image, w, h)
    image = ScoreTools.center!(image)
    image
end

out_file_prefix = "out"
page = '0000'
double_page = false
name = 'out'
width, height = 0, 0
prerotate = 0

i = 0
while(ARGV[i] =~ /^-/)
    if(ARGV[i] == '-double-page')
        double_page = true
    elsif(ARGV[i] == '-prerotate')
        i += 1
        prerotate = ARGV[i].to_i
    elsif(ARGV[i] == '-name')
        i += 1
        name = ARGV[i]
    elsif(ARGV[i] == '-prefix')
        i += 1
        out_file_prefix = ARGV[i]
    elsif(ARGV[i] == '-size')
        i += 1
        width, height = ARGV[i].split('x').map{|x|x.to_i}
    end
    i += 1
end

if(width == 0 || height==0)
    puts "Invalid size"
    exit
end

files = ARGV[i..-1]
files.each do |file|
    puts page
    image = Leptonica::Pix.read(file)

    if(prerotate > 0 && prerotate < 4)
        puts "prerotate: #{prerotate}"
        image = image.rotate_orth(prerotate)
    end

    if(double_page)
        puts "split page"
        left, right = ScoreTools.split_in_half(image)

        puts "clean left page"
        left = clean_image(left, width, height)
        left.write("#{out_file_prefix}#{page}.tiff", :tiff_g4)
        page.succ!

        #Free the image (hopefully)
        GC.start

        puts "clean right page"
        right = clean_image(right, width, height)
        right.write("#{out_file_prefix}#{page}.tiff", :tiff_g4)
        page.succ!
    else
        puts "clean page"
        image = clean_image(image, width, height)
        image.write("#{out_file_prefix}#{page}.tiff", :tiff_g4)
        page.succ!
    end

    #Free the image (hopefully)
    GC.start
end

ScoreTools.files_to_pdf(Dir["out*.tiff"].sort, name)

