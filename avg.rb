require 'RMagick'
include Magick

frames = `ls frames | grep png`.split("\n")

final = Image.new(1, 1)

frames.each do |f|
  p f
  img = Image.read("frames/#{f}").first
  final = img.scale(1,1).blend(final, 0.5)
  img.destroy! # don't fill up RAM oops
end

puts final.pixel_color(0,0)

large = Image.new(512,512) {
  self.background_color = final.pixel_color(0, 0)
}

large.write('output.png')
