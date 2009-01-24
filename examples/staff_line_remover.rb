#!/usr/bin/env ruby

#
#This is a very rudimentary staff line removal algorithm:
#
#1. Find horizontal lines with a horizontal opening. Clean this up somewhat by
#ANDing a dilation of this result with the original image.
#2. Find vertical sections which are longer than the staff line height. These
#sections should not be removed so subtract this from the line approximation
#above.
#3. Subtract the line approximation from the original image.
#
#This isn't very sophisticated, but it show that with a few simple building
#blocks a fairly complex task can be accomplished.
#

SCRIPT_DIR = File.dirname($0)
$LOAD_PATH << "#{SCRIPT_DIR}/../lib"

require 'rubygems'
require 'leptonica'

horizontal = 101
vertical = 13
smudge_factor = 7

image = Leptonica::Pix.read(ARGV[0])
image = image.deskew
lines = image.open_brick(horizontal, 1).dilate_brick!(1, smudge_factor).and!(image)
dont_remove = image.open_brick(1, vertical)
image = image.subtract(lines.subtract(dont_remove))
image.write(ARGV[1], :tiff_g4)
