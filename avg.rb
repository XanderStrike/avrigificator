#!/usr/bin/env ruby
require 'RMagick'
require 'sqlite3'
require 'streamio-ffmpeg'
include Magick

# === settings ===

# process one frame every SECONDS
#  larger is faster
#  smaller is more accurate
SECONDS = 5

# process every RES pixel from each frame
#  larger is faster
#  smaller is prettier and creates a larger final image
RES = 2


# === the actual program and stuff ===

if ARGV.first.nil?
  puts "Usage: ./avg.rb [filename]"
  exit
end

def clean_up
  `rm frames/*` rescue nil
  `rm pixels.db` rescue nil
end

def explode filename
  video = FFMPEG::Movie.new(filename)
  (video.duration / SECONDS).to_i.times do |x|
    video.screenshot("frames/#{x.to_s.rjust(5, "0")}.png", seek_time: (x * SECONDS))
  end
end

def create_table db
  db.execute <<-SQL
    create table pixels (
      frame int,
      x int,
      y int,
      red int,
      green int,
      blue int
    );
  SQL
end

def insert_pixel db, frame, x, y, color
  values = [frame, x, y, color.red, color.green, color.blue]
  db.execute "insert into pixels (frame, x, y, red, green, blue) values (?, ?, ?, ?, ?, ?)", values
end

def insert_frame db, n, frame
  (frame.columns / RES).times do |x|
    (frame.rows / RES).times do |y|
      insert_pixel db, n, x, y, frame.pixel_color(x * RES, y * RES)
    end
  end
end

def populate db
  frames = `ls frames | grep png`.split("\n")

  total_frames = frames.count
  total_frames.times do |n|
    print "\rProcessing frame #{n + 1} of #{total_frames}..."
    img = Image.read("frames/#{frames[n]}").first
    insert_frame db, n, img
    img.destroy! # don't fill up RAM ;)
  end
  puts "\nDone."
end

def get_pixels db, img
  puts "Building image..."
  img.tap do |i|
    i.columns.times do |x|
      i.rows.times do |y|
        rgb = db.execute('select avg(red), avg(green), avg(blue) from pixels where x = ? and y = ?', x, y).first
        i.store_pixels(x, y, 1, 1, [Pixel.new(rgb[0], rgb[1], rgb[2], 0)])
      end
    end
  end
end

def process db
  size = db.execute('select max(x), max(y) from pixels').first

  img = Image.new(size[0], size[1])

  img = get_pixels(db, img)

  puts "Saving as output.png.."
  img.write('output.png')
  puts "Done."
end

# run like the wind
start = Time.now
clean_up

db = SQLite3::Database.new "pixels.db"
create_table db

explode ARGV.first
populate db
process db

clean_up
puts "Completed in #{Time.now - start} seconds."
