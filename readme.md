#avrigificator

Simple script to get the average color of all frames in a video file.

Requires ImageMagick, avconv (or ffmpeg) and the RMagick gem.

Usage: `./avg.rb path/to/file.mp4`

WARNING: This takes a while, and uses an absolute _shitload_ of HDD space during the process. A 5 minute, 720p video can be expected to take up several gigs. SSDs make it way faster.


TODO: multithreading
