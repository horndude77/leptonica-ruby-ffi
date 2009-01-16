#!/usr/bin/env ruby

#This script determines the staff line height and staff space for a given
#score.

SCRIPT_DIR = File.dirname($0)
$LOAD_PATH << SCRIPT_DIR
$LOAD_PATH << "#{SCRIPT_DIR}/../lib"

require 'rubygems'
require 'leptonica'
require 'score_tools'

image = Leptonica::Pix.read(ARGV[0])
height, space = ScoreTools.estimate_staff_parameters(image)
puts "Staff line height: #{height}, Staff space: #{space}"

