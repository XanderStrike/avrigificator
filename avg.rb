require 'RMagick'
include Magick

frames = `ls frames | grep png`.split("\n")

final = Image.new(1, 1)

frames.each do |f|
  p f
  img = Image.read("frames/#{f}").first.scale(1,1)
  final = img.blend(final, 0.5)
end

puts final.pixel_color(0,0)
large = Image.new(512,512) {
  self.background_color = final.pixel_color(0, 0)
}

large.write('output.png')
