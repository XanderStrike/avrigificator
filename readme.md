#avrigificator

### purpose

This script _averages_ a video into a single image.

### usage

System requirements: ImageMagick, ffmpeg, sqlite3

Gems: rmagick, sqlite3, streamio-ffmpeg

Modify the values in `avg.rb` to suit your needs first.

Run: `./avg.rb path/to/file.mp4`

Result: `output.png`

WARNING: Depending on your settings, this can take a very long time, and take a lot of hard drive space. Start with high numbers for the settings to get a feel for what they do.
