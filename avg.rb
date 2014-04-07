#!/usr/bin/env ruby

require 'RMagick'
include Magick

if ARGV.first.nil?
  puts "Usage: ./avg.rb [filename]"
  exit
end

`rm frames/*`

# explode video into frames
p `avconv -i "#{ARGV.first}" -r 1000 -f image2 frames/image-%07d.png`

# get list of frames
frames = `ls frames | grep png`.split("\n")

final = Image.new(1, 1)

# for each frame, get average color then blend with final
frames.each do |f|
  p f
  img = Image.read("frames/#{f}").first
  final = img.scale(1,1).blend(final, 0.5)
  img.destroy! # don't fill up RAM
end

puts final.pixel_color(0,0)

# save
large = Image.new(512,512) {
  self.background_color = final.pixel_color(0, 0)
}

large.write('output.png')
